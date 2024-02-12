#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/init-build-env.sh"

prompt_yes_no() {
  local Prompt=$1
  while : ; do
    read -p $Prompt
    [[ $REPLY == "y" || $REPLY == "Y" || $REPLY == "n" || $REPLY == "N" ]] && break
  done
  if [[ $REPLY == "Y" || $REPLY == "y" ]]; then
    return 0;
  else
    return 1;
  fi
}

setup_repo() {
  local Name=$1
  local GitURL=$2
  local GitBranch=$3

  local TargetPath=$(get_conf_var $Name)
  local Clone=true

  echo "-- Setup $Name repo in $TargetPath"
  if test -d "$TargetPath"; then
    pushd "$TargetPath" > /dev/null
    local IsRepo=$(git rev-parse --is-inside-work-tree)
    popd > /dev/null
    if [[ "$IsRepo" == "true" ]]; then
      echo "   Repo already exists at $TargetPath."
      Clone=false
    elif [ -z "$(ls -A "$TargetPath")" ]; then
      echo "   $TargetPath already exists but is empty."
    else
      echo "   $TargetPath already exists and is not a git repo. Cannot continue."
      return 1
    fi
  elif test -f $TargetPath; then
    echo "   $TargetPath is a file. Cannot clone $Name repo here"
    return 1
  fi

  if $Clone; then
    echo "   Creating target directory $TargetPath"
    mkdir -p "$TargetPath"

    echo "   Cloning $GitURL@$GitBranch to $TargetPath"
    pushd "$TargetPath" > /dev/null
    git clone -b $GitBranch $GitURL .
    popd > /dev/null
  fi

  pushd "$TargetPath" > /dev/null
  local CurrentBranch=$(git rev-parse --abbrev-ref HEAD)

  if ! [[ "$CurrentBranch" == "$GitBranch" ]]; then
    if prompt_yes_no "   Switch branch from $CurrentBranch to $GitBranch (working tree changes will be stashed) [Y/n]? "; then
      pushd "$TargetPath" > /dev/null
      echo "   Checking out $GitBranch"
      git stash
      git checkout "$GitBranch"
    fi
  else
    echo "   Already checked out the target branch ($GitBranch)"
  fi

  popd > /dev/null
  return 0
}

mamba_env_exists() {
  local EnvName=$1
  if test -d $MAMBA_ROOT_PREFIX/envs/$EnvName; then
    return 0
  else
    return 1
  fi
}

echo "-- Configuring paths"
configure_path "react-swift-dir" "$HOME/react-swift"
configure_path "swift-dir" "$HOME/swift"
configure_path "emscripten-forge-dir" "$HOME/emscripten-forge"
configure_path "pyjs-code-runner-dir" "$HOME/pyjs-code-runner"
configure_path "emsdk-dir" "$HOME/emsdk"

echo "-- Cloning dependencies"
setup_repo "react-swift-dir" "https://github.com/mbatc/react-swift.git" "emscripten"
setup_repo "swift-dir" "https://github.com/mbatc/swift.git" "emscripten"
setup_repo "emscripten-forge-dir" "https://github.com/emscripten-forge/recipes.git" "main"
setup_repo "pyjs-code-runner-dir" "https://github.com/emscripten-forge/pyjs-code-runner" "main"

EMFORGE_DIR=$(get_conf_var "emscripten-forge-dir")
SWIFT_DIR=$(get_conf_var "swift-dir")
REACT_SWIFT_DIR=$(get_conf_var "react-swift-dir")
PYJS_RUNNER_DIR=$(get_conf_var "pyjs-code-runner-dir")


if mamba_env_exists $RUNNER_ENV_NAME; then
  echo "-- Skip creating pyjs runner env for mamba. $RUNNER_ENV_NAME already exists"
else
  echo "-- Creating pyjs runner env for mamba($RUNNER_ENV_NAME)"
  micromamba create \
      -n $RUNNER_ENV_NAME \
      -c conda-forge python \
      -y
  micromamba activate $RUNNER_ENV_NAME
  pushd "$PYJS_RUNNER_DIR"
  python -m pip install -e .
  popd
  playwright install
fi


if mamba_env_exists $EMFORGE_ENV_NAME; then
  echo "-- Skip setting up emscripten forge environment for mamba. $EMFORGE_ENV_NAME already exists"
else
  echo "-- Setting up emscripten forge environment for mamba ($EMFORGE_ENV_NAME)"
  micromamba create \
      -n $EMFORGE_ENV_NAME \
      -f $EMFORGE_DIR/ci_env.yml \
      --yes
  micromamba activate $EMFORGE_ENV_NAME
  playwright install

  bash "$EMFORGE_DIR/emsdk/setup_emsdk.sh" $EMSDK_VERSION $(get_conf_var "emsdk-dir")
  python -m pip install git+https://github.com/DerThorsten/boa.git@python_api_v2

  micromamba config append channels https://repo.mamba.pm/emscripten-forge --env
fi


if mamba_env_exists $WEB_ENV_NAME; then
  echo "-- Skip creating web environment for mamba. $WEB_ENV_NAME already exists"
else
  echo "-- Creating web environment for mamba ($WEB_ENV_NAME)"
  micromamba create \
      --platform=emscripten-wasm32 \
      -f $ROOT_DIR/envs/web-env.yaml  \
      -n $WEB_ENV_NAME \
      -c https://repo.mamba.pm/emscripten-forge \
      -c https://repo.mamba.pm/conda-forge -y
  # Add local build repo and emscripten forge
  micromamba config append channels $MAMBA_ROOT_PREFIX/envs/$EMFORGE_ENV_NAME/conda-bld --env
  micromamba config append channels https://repo.mamba.pm/emscripten-forge --env
  # Remove conda-forge channel (doesn't contain emscripten-32 packages)
  micromamba config remove channels conda-forge --env
fi


if mamba_env_exists $REACT_SWIFT_ENV_NAME; then
  echo "-- Skip react-swift build environment for mamba. $REACT_SWIFT_ENV_NAME already exists"
else
  echo "-- Creating react-swift build environment for mamba ($REACT_SWIFT_ENV_NAME)"
  micromamba create -n $REACT_SWIFT_ENV_NAME -f $ROOT_DIR/envs/react-swift-env.yaml --yes
fi
