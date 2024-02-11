#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-build-env.sh

if test -z $REACT_SWIFT_DIR; then
  DEFAULT_REACT_SWIFT_DIR="~/react-swift"
  echo " -- Configure react-swift path"
  read -p "Where should we clone to (default is $DEFAULT_REACT_SWIFT_DIR)?: " REACT_SWIFT_DIR

  if test -z $REACT_SWIFT_DIR; then
    REACT_SWIFT_DIR=$DEFAULT_REACT_SWIFT_DIR
  fi
fi

if test -z $SWIFT_DIR; then
  DEFAULT_SWIFT_DIR="~/swift"
  echo " -- Configure Swift path"
  read -p "Where should we clone to (default is $DEFAULT_SWIFT_DIR)?: " SWIFT_DIR
  
  if test -z $SWIFT_DIR; then
    SWIFT_DIR=$DEFAULT_SWIFT_DIR
  fi
fi

if test -z $EMFORGE_DIR; then
  DEFAULT_EMFORGE_DIR="~/emscripten-forge"
  echo " -- Configure emscripten forge recipes path"
  read -p "Where should we clone to (default is $DEFAULT_EMFORGE_DIR)?: " EMFORGE_DIR

  if test -z $EMFORGE_DIR; then
    EMFORGE_DIR=$DEFAULT_EMFORGE_DIR
  fi
fi

if test -z $PYJS_RUNNER_DIR; then
  DEFAULT_PYJS_RUNNER_DIR="~/pyjs-code-runner"
  echo " -- Configure pyjs-code-runner path"
  read -p "Where should we clone to (default is $DEFAULT_PYJS_RUNNER_DIR)?: " PYJS_RUNNER_DIR

  if test -z $PYJS_RUNNER_DIR; then
    PYJS_RUNNER_DIR=$DEFAULT_PYJS_RUNNER_DIR
  fi
fi

if test -z $EMSDK_DIR; then
  DEFAULT_EMSDK_DIR="~/emsdk"
  echo " -- Configure emsdk path"
  read -p "Where should we install emsdk to (default is $DEFAULT_EMSDK_DIR)?: " EMSDK_DIR

  if test -z $EMSDK_DIR; then
    EMSDK_DIR=$DEFAULT_EMSDK_DIR
  fi
fi

echo "-- Cloning dependencies"
git clone -b "$_REACT_SWIFT_BRANCH" "$_REACT_SWIFT_GIT_URL"
git clone -b "$_SWIFT_BRANCH" "$_SWIFT_GIT_URL"
git clone -b "$_EMFORGE_BRANCH" "$_EMFORGE_GIT_URL"
git clone -b "$_PYJS_RUNNER_GIT_BRANCH" "$_PYJS_RUNNER_GIT_URL"

echo "-- Creating pyjs runner env ($RUNNER_ENV_NAME)"
micromamba create \
    -n $RUNNER_ENV_NAME \
    -c conda-forge python \
    -y
micromamba activate $RUNNER_ENV_NAME
pushd "$PYJS_RUNNER_DIR"
python -m pip install -e .
popd
playwright install

echo "-- Setting up emscripten forge environment ($EMFORGE_ENV_NAME)"
micromamba create \
    -n $EMFORGE_ENV_NAME \
    -f $EMFORGE_DIR/ci_env.yml \
    --yes
micromamba activate $EMFORGE_ENV_NAME
micromamba config append channels https://repo.mamba.pm/emscripten-forge --env
playwright install
bash "$EMFORGE_DIR/emsdk/setup_emsdk.sh" 3.1.45 ~/emsdk
python -m pip install git+https://github.com/DerThorsten/boa.git@python_api_v2

echo "-- Creating web environment ($WEB_ENV_NAME)"
micromamba create \
    --platform=emscripten-wasm32 \
    -f $ROOT_DIR/envs/web-env.yaml  \
    -n $WEB_ENV_NAME \
    -c https://repo.mamba.pm/emscripten-forge \
    -c https://repo.mamba.pm/conda-forge -y

echo "-- Creating react-swift build environment ($REACT_SWIFT_ENV_NAME)"
micromamba create -n $REACT_SWIFT_ENV_NAME -f $ROOT_DIR/env/react-swift-env.yaml --yes
