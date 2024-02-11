#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-build-envs.sh

pushd $ROOT_DIR
git subtree push --prefix dist origin gh-pages
popd
