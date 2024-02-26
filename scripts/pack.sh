#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/init-build-env.sh"

micromamba activate $EMFORGE_ENV_NAME

rm -r -f $DIST_DIR
mkdir $DIST_DIR

empack pack env \
    --env-prefix "$MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME" \
    --config $EMPACK_CONF \
    --outdir $DIST_DIR

echo "-- ls $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME"
ls $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME
echo "-- ls $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME/lib"
ls $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME/lib
echo "-- ls $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME/lib/pyjs"
ls $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME/lib/pyjs

cp -a $MAMBA_ROOT_PREFIX/envs/$WEB_ENV_NAME/lib_js/pyjs/. $DIST_DIR
cp -a $SRC_DIR/. $DIST_DIR
cp -a "$(get_conf_var "swift-dir")/swift/out/." $DIST_DIR/swift

echo "Site deployed to $DIST_DIR"
echo "To host the site on a server run,"
echo ""
echo "  python -m http.server 8080 --directory $DIST_DIR"
echo ""
echo "  or alternatively use,"
echo ""
echo "  ./run.sh"
echo ""

micromamba deactivate
