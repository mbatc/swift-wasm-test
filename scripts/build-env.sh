#!/bin/bash -i

eval "$(micromamba shell hook --shell bash)"

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
DIST_DIR=$ROOT_DIR/dist
SRC_DIR=$ROOT_DIR/site
EMPACK_CONF=$SCRIPT_DIR/empack_config.yaml

get_conf_path() {
  local PathName=$1
  local CacheFile="$ROOT_DIR/conf/.$PathName-dir"

  if test -f "$CacheFile"; then
    echo -n $(cat "$CacheFile")
  fi
}

configure_path() {
  local PathName=$1
  local DefaultPath=$2
  local CacheFile="$ROOT_DIR/conf/.$PathName-dir"
  local CurrentPath=$(get_conf_path "$PathName")

  echo "-- Configure '$PathName' path"

  if test -z $CurrentPath; then
    read -p "   Set path for '$PathName' (default is $DefaultPath)?: " CurrentPath

    if test -z $CurrentPath; then
      CurrentPath=$DefaultPath
    fi

    # Resolve the full path before saving it
    CurrentPath=$(get_cannon_path "$CurrentPath")

    mkdir -p "$ROOT_DIR/conf"
    echo -n "$CurrentPath">"$CacheFile"
  else
    echo "   $PathName path is configured to $CurrentPath. Delete $CacheFile to reconfigure this."
  fi
}

EMFORGE_ENV_NAME="emscripten-forge"
RUNNER_ENV_NAME="pyjs-code-runner"
WEB_ENV_NAME="pyjs-wasm-env"
REACT_SWIFT_ENV_NAME="react-swift"
EMSDK_VERSION="3.1.45"

echo "-- Build env variables"
echo "   SCRIPT_DIR:           $SCRIPT_DIR"
echo "   CANON_SCRIPT_DIR:     $CANON_SCRIPT_DIR"
echo "   ROOT_DIR:             $ROOT_DIR"
echo "   DIST_DIR:             $DIST_DIR"
echo "   SRC_DIR:              $SRC_DIR"
echo "   EMPACK_CONF:          $REACT_SWIFT_ENV_NAME"
echo ""
echo "   EMFORGE_ENV_NAME:     $EMFORGE_ENV_NAME"
echo "   RUNNER_ENV_NAME:      $RUNNER_ENV_NAME"
echo "   WEB_ENV_NAME:         $WEB_ENV_NAME"
echo "   REACT_SWIFT_ENV_NAME: $REACT_SWIFT_ENV_NAME"
echo ""
echo "   EMSDK_VERSION:        $EMSDK_VERSION"
echo "   Configured Paths (see get_conf_path):"
echo "     react-swift:        $(get_conf_path "react-swift")"
echo "     swift:              $(get_conf_path "swift")"
echo "     emscripten-forge:   $(get_conf_path "emscripten-forge")"
echo "     pyjs-code-runner:   $(get_conf_path "pyjs-code-runner")"
echo "     emsdk:              $(get_conf_path "emsdk")"
echo ""
