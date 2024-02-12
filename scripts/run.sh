#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/init-build-env.sh"

micromamba activate $EMFORGE_ENV_NAME
python -m http.server --directory $DIST_DIR
micromamba deactivate
