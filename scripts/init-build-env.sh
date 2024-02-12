#!/bin/bash -i

eval "$(micromamba shell hook --shell bash)"

eval_template() {
  eval "echo \"$(cat $ROOT_DIR/recipes/swift-sim/recipe.yaml.in)\""
}

get_cannon_path() {
  if test -f $1 || test -d $1; then
    echo $(cd "$1"; pwd)
  else
    mkdir -p "$1"
    echo $(cd "$1"; pwd)
    rm -r "$1"
  fi
}

# Dependency repo paths
SCRIPT_DIR=$(dirname "$0")
CANON_SCRIPT_DIR=$(get_cannon_path "$SCRIPT_DIR")
ROOT_DIR=$CANON_SCRIPT_DIR/..
CONFIG_DIR=$ROOT_DIR/conf
DIST_DIR=$ROOT_DIR/dist
SRC_DIR=$ROOT_DIR/site
EMPACK_CONF=$ROOT_DIR/empack_config.yaml

get_var_path() {
  echo "$CONFIG_DIR/$1"
}

set_conf_var() {
  # Set a config variable that can be retrieved with get_config_var.
  # Values are saved to the conf/ directory in a file with name of the variable.
  # Delete the file associated with a variable to reset it.
  local Name=$1
  local Value=$2
  local CacheFile=$(get_var_path "$Name")
  mkdir -p $(dirname "$CacheFile")
  echo -n "$Value">"$CacheFile"
  echo "-- Set '$Name' to "$Value""
}

get_conf_var() {
  # Get a config variable previously set with set_config_var.
  # To read a value to a variable you should use the syntax 'MyVariable=$(get_config_var variableName)''
  local Name=$1
  local CacheFile=$(get_var_path "$Name")
  if test -f "$CacheFile"; then
    echo -n $(cat "$CacheFile")
  fi
}

delete_conf_var() {
  local CacheFile=$(get_var_path "$Name")
}

configure_path() {
  # Prompt the user to configure a path if it is not set.
  # Saves the path provided as a config variable which can be retrieved with get_config_var.
  local PathName=$1
  local DefaultPath=$2
  local CurrentPath=$(get_conf_var "$PathName")

  echo "-- Configure '$PathName' path"

  if test -z $CurrentPath; then
    read -p "   Set path for '$PathName' (default is $DefaultPath)?: " CurrentPath

    if test -z $CurrentPath; then
      CurrentPath=$DefaultPath
    fi

    # Resolve the full path before saving it
    CurrentPath=$(get_cannon_path "$CurrentPath")

    set_conf_var "$PathName" "$CurrentPath"
  else
    echo "   $PathName path is configured to $CurrentPath. Delete $(get_var_path "$PathName") to reconfigure this."
  fi
}

EMFORGE_ENV_NAME="emscripten-forge"
RUNNER_ENV_NAME="pyjs-code-runner"
WEB_ENV_NAME="pyjs-wasm-env"
REACT_SWIFT_ENV_NAME="react-swift"
EMSDK_VERSION="3.1.45"

echo "-- Build env variables"
echo "   SCRIPT_DIR:             $SCRIPT_DIR"
echo "   CANON_SCRIPT_DIR:       $CANON_SCRIPT_DIR"
echo "   ROOT_DIR:               $ROOT_DIR"
echo "   DIST_DIR:               $DIST_DIR"
echo "   SRC_DIR:                $SRC_DIR"
echo "   EMPACK_CONF:            $REACT_SWIFT_ENV_NAME"
echo ""
echo "   EMFORGE_ENV_NAME:       $EMFORGE_ENV_NAME"
echo "   RUNNER_ENV_NAME:        $RUNNER_ENV_NAME"
echo "   WEB_ENV_NAME:           $WEB_ENV_NAME"
echo "   REACT_SWIFT_ENV_NAME:   $REACT_SWIFT_ENV_NAME"
echo ""
echo "   EMSDK_VERSION:          $EMSDK_VERSION"

echo "   Build Variables (see get_conf_var/set_conf_var):"
for path in $CONFIG_DIR/*; do
  file=$(basename $path)
  echo "     $file=$(get_conf_var "$file")"
done
