#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-build-envs.sh

python -m http.server --directory $DEPLOY_DIR
