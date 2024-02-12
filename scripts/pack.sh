#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/build-env.sh

micromamba activate $EMFORGE_ENV_NAME

rm -r -f $DEPLOY_DIR
mkdir $DEPLOY_DIR

empack pack env \
    --env-prefix "$MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME" \
    --config $EMPACK_CONF \
    --outdir $DEPLOY_DIR

cp -a $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME/lib_js/pyjs/. $DEPLOY_DIR
cp -a $SRC_DIR/. $DEPLOY_DIR
cp -a $SWIFT_DIR/swift/out/. $DEPLOY_DIR/swift

echo "Site deployed to $DEPLOY_DIR"
echo "To host the site on a server run,"
echo ""
echo "  python -m http.server 8080 --directory $DEPLOY_DIR"
echo ""
echo "  or alternatively use,"
echo ""
echo "  ./run.sh"
echo ""

micromamba deactivate
