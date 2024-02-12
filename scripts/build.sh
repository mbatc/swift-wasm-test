#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/build-env.sh

SWIFT_DIR=$(get_conf_path "swift")

micromamba activate $EMFORGE_ENV_NAME
pushd "$(get_conf_path "emscripten-forge")"
python builder.py build explicit $CANON_SCRIPT_DIR/../recipes/swift-sim --emscripten-wasm32 --no-skip-existing
popd
micromamba deactivate

micromamba activate $REACT_SWIFT_ENV_NAME
pushd "$(get_conf_path "react-swift")"
npm install
rm -r dist
npm run build
popd

pushd "$SWIFT_DIR/next-swift"
rm -r ../swift/out
npm install
npm run build
popd
micromamba deactivate

micromamba activate $WEB_ENV_NAME
micromamba install swift-sim -y
micromamba update  swift-sim -y

source $SCRIPT_DIR/pack.sh

micromamba deactivate
