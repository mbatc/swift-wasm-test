
eval "$(micromamba shell hook --shell bash)"

micromamba activate emscripten-forge

WASM_ENV=pyjs-wasm-env

SCRIPT_DIR=$(dirname "$0")

SRC_DIR=$SCRIPT_DIR/site
SWIFT_DIR=$SCRIPT_DIR/swift
DEPLOY_DIR=$SCRIPT_DIR/dist
EMPACK_CONF=$SCRIPT_DIR/empack_config.yaml

rm -r -f $DEPLOY_DIR
mkdir $DEPLOY_DIR

if [ ! -f $EMPACK_CONF ]; then
    curl https://raw.githubusercontent.com/emscripten-forge/recipes/main/empack_config.yaml --output $EMPACK_CONF
fi

empack pack env \
    --env-prefix "$MAMBA_ROOT_PREFIX/envs/$WASM_ENV" \
    --config $EMPACK_CONF \
    --outdir $DEPLOY_DIR

cp -a $MAMBA_ROOT_PREFIX/envs/$WASM_ENV/lib_js/pyjs/. $DEPLOY_DIR
cp -a $SRC_DIR/. $DEPLOY_DIR
cp -a $SWIFT_DIR/swift/public/. $DEPLOY_DIR/swift

echo "Site deployed to $DEPLOY_DIR"
echo "To host the site on a server run,"
echo ""
echo "  python -m http.server 8080 --directory $DEPLOY_DIR"
echo ""

micromamba deactivate