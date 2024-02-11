#!/bin/bash -i

eval "$(micromamba shell hook --shell bash)"

# Dependency repo paths
_EMFORGE_GIT_URL="https://github.com/emscripten-forge/recipes.git"
_EMFORGE_BRANCH="main"
_REACT_SWIFT_GIT_URL="https://github.com/mbatc/react-swift.git"
_REACT_SWIFT_BRANCH="emscripten"
_SWIFT_GIT_URL="https://github.com/mbatc/swift.git"
_SWIFT_GIT_BRANCH="emscripten"
_PYJS_RUNNER_GIT_URL="https://github.com/emscripten-forge/pyjs-code-runner"
_PYJS_RUNNER_GIT_BRANCH="main"

SCRIPT_DIR=$(dirname "$0")
CANON_SCRIPT_DIR=$(cd "$SCRIPT_DIR"; pwd)
ROOT_DIR=$CANON_SCRIPT_DIR/../
DIST_DIR=$ROOT_DIR/dist
SRC_DIR=$ROOT_DIR/site
EMPACK_CONF=$SCRIPT_DIR/empack_config.yaml

_REACT_SWIFT_DIR_FILE="$ROOT_DIR/.react-swift-dir"
_SWIFT_DIR_FILE="$ROOT_DIR/.swift-dir"
_EMFORGE_DIR_FILE="$ROOT_DIR/.emscripten-forge-dir"
_PYJS_RUNNER_DIR_FILE="$ROOT_DIR/.pyjs-code-runner-dir"
_EMSDK_DIR_FILE="$ROOT_DIR/.emsdk-dir"

if test -f "$_REACT_SWIFT_DIR_FILE"; then
  REACT_SWIFT_DIR=$(cat "$_REACT_SWIFT_DIR_FILE")
else
  REACT_SWIFT_DIR=""
fi

if test -f "$_SWIFT_DIR_FILE"; then
  SWIFT_DIR=$(cat "$_SWIFT_DIR_FILE")
else
  SWIFT_DIR=""
fi

if test -f "$_EMFORGE_DIR_FILE"; then
  EMFORGE_DIR=$(cat "$_EMFORGE_DIR_FILE")
else
  EMFORGE_DIR=""
fi

if test -f "$_PYJS_RUNNER_DIR_FILE"; then
  PYJS_RUNNER_DIR=$(cat "$_PYJS_RUNNER_DIR_FILE")
else
  PYJS_RUNNER_DIR=""
fi

if test -f "$_EMSDK_DIR_FILE"; then
  EMSDK_DIR=$(cat "$_EMSDK_DIR_FILE")
else
  EMSDK_DIR=""
fi

EMFORGE_ENV_NAME="emscripten-forge"
RUNNER_ENV_NAME="pyjs-code-runner"
WEB_ENV_NAME="pyjs-wasm-env"
REACT_SWIFT_ENV_NAME="react-swift"
EMSDK_VERSION="3.1.45"

echo "SCRIPT_DIR:           $SCRIPT_DIR"
echo "CANON_SCRIPT_DIR:     $CANON_SCRIPT_DIR"
echo "ROOT_DIR:             $ROOT_DIR"
echo "DIST_DIR:             $DIST_DIR"
echo "SRC_DIR:              $SRC_DIR"
echo "EMPACK_CONF:          $REACT_SWIFT_ENV_NAME"
echo ""
echo "EMFORGE_ENV_NAME:     $EMFORGE_ENV_NAME"
echo "RUNNER_ENV_NAME:      $RUNNER_ENV_NAME"
echo "WEB_ENV_NAME:         $WEB_ENV_NAME"
echo "REACT_SWIFT_ENV_NAME: $REACT_SWIFT_ENV_NAME"
echo ""
echo "REACT_SWIFT_DIR:      $REACT_SWIFT_DIR"
echo "SWIFT_DIR:            $SWIFT_DIR"
echo "EMFORGE_DIR:          $EMFORGE_DIR"
echo "PYJS_RUNNER_DIR:      $PYJS_RUNNER_DIR"
echo "EMSDK_DIR:            $EMSDK_DIR"
echo "EMSDK_VERSION:        $EMSDK_VERSION"
