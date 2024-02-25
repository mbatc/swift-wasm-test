#!/bin/bash -i

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/init-build-env.sh"

# Path to the swift recipe
RECIPE_PATH=$ROOT_DIR/recipes/swift-sim/recipe.yaml
# Set variables used in the recipe template
SWIFT_DIR=$(get_conf_var "swift-dir")
LAST_BUILD_NUMBER=$(get_conf_var "build-number")
# Increment build number for next build
let BUILD_NUMBER=$LAST_BUILD_NUMBER+1
set_conf_var "build-number" $BUILD_NUMBER
# Export the swift recipe. This is a roundabout way of setting the local path
# and incrementing the build number each time the recipe is built.
RECIPE=$(eval_template $RECIPE_PATH.in)
echo "$RECIPE">$RECIPE_PATH

echo "-- Activating $EMFORGE_ENV_NAME"
micromamba activate $EMFORGE_ENV_NAME
RECIPE_DIR=$(dirname "$RECIPE_PATH")
pushd "$(get_conf_var "emscripten-forge-dir")" > /dev/null
python builder.py build explicit $RECIPE_DIR --emscripten-wasm32 --no-skip-existing
popd > /dev/null
micromamba deactivate

echo "-- Activating $REACT_SWIFT_ENV_NAME"
micromamba activate $REACT_SWIFT_ENV_NAME
pushd "$(get_conf_var "react-swift-dir")" > /dev/null
npm install
rm -r dist
npm run build
popd

pushd "$SWIFT_DIR/next-swift" > /dev/null
rm -r ../swift/out
npm install
npm run build
popd > /dev/null
micromamba deactivate

echo "-- Activating $WEB_ENV_NAME"
micromamba activate $WEB_ENV_NAME
micromamba install swift-sim \
      -c $MAMBA_ROOT_PREFIX/envs/$EMFORGE_ENV_NAME/conda-bld\
      -c https://repo.mamba.pm/emscripten-forge \
      -c https://repo.mamba.pm/conda-forge -y
micromamba update  swift-sim \
      -c $MAMBA_ROOT_PREFIX/envs/$EMFORGE_ENV_NAME/conda-bld\
      -c https://repo.mamba.pm/emscripten-forge \
      -c https://repo.mamba.pm/conda-forge -y

source $SCRIPT_DIR/pack.sh

micromamba deactivate
