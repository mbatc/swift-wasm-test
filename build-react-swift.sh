
eval "$(micromamba shell hook --shell bash)"

SCRIPT_DIR=$(dirname "$0")
CANON_SCRIPT_DIR=$(cd "$SCRIPT_DIR"; pwd)

micromamba activate react-swift
pushd $SCRIPT_DIR/react-swift
# node --version
# npm --version
npm install
rm -r dist
npm run build
popd

pushd $SCRIPT_DIR/swift/next-swift
rm -r ../swift/out
npm install
npm run build
popd
micromamba deactivate

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/pack.sh

micromamba deactivate
