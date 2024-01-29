
eval "$(micromamba shell hook --shell bash)"

micromamba activate emscripten-forge
pushd ~/emscripten-forge
python builder.py build explicit recipes/recipes_emscripten/swift-sim --emscripten-wasm32 --no-skip-existing
popd

micromamba activate pyjs-wasm-env
micromamba install swift-sim -y
micromamba update  swift-sim -y

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/pack.sh
