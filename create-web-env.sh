#!/bin/bash -i

eval "$(micromamba shell hook --shell bash)"

ENV_NAME=pyjs-wasm-env

SCRIPT_DIR=$(dirname "$0")

micromamba create \
    --platform=emscripten-wasm32 \
    -f $SCRIPT_DIR/envs/web-env.yaml  \
    -n $ENV_NAME \
    -c https://repo.mamba.pm/emscripten-forge \
    -c https://repo.mamba.pm/conda-forge -y
