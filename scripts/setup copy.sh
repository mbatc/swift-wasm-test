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

echo "SCRIPT_DIR:           $SCRIPT_DIR"
echo "CANON_SCRIPT_DIR:     $CANON_SCRIPT_DIR"
echo "ROOT_DIR:             $ROOT_DIR"
echo "DIST_DIR:             $DIST_DIR"
echo "SRC_DIR:              $SRC_DIR"
echo "EMPACK_CONF:          $REACT_SWIFT_ENV_NAME"

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
    read -p "Set path for '$PathName' (default is $DefaultPath)?: " CurrentPath

    if test -z $CurrentPath; then
      CurrentPath=$DefaultPath
    fi

    # Resolve the full path before saving it
    CurrentPath=$(get_cannon_path "$CurrentPath")

    mkdir -p "$ROOT_DIR/conf"
    echo -n "$CurrentPath">"$CacheFile"
  else
    echo "'$PathName' path is configured to $CurrentPath. Delete $CacheFile to reconfigure this."
  fi
}

echo "Current path is $(get_conf_path test)"
