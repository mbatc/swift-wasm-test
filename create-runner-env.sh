#!/bin/bash -i

eval "$(micromamba shell hook --shell bash)"

ENV_NAME=pyjs-code-runner

SCRIPT_DIR=$(dirname "$0")

micromamba create -n $ENV_NAME -c conda-forge python -y
micromamba activate $ENV_NAME

git clone https://github.com/emscripten-forge/pyjs-code-runner

pushd pyjs-code-runner
python -m pip install -e .
popd

playwright install
