# Swift WASM Test

This repo contains a test web page that hosts the [Swift Robotics Simulator](https://github.com/jhavl/swift) entirely within a browser. The swift python package is cross-compiled to Web Assembly with [Emscripten Forge](https://github.com/emscripten-forge/recipes) and loaded in the browser using [Empack](https://github.com/emscripten-forge/empack) and [PyJS](https://github.com/emscripten-forge/pyjs.git). The Swift python package did have to be modified to work in the Web environment as it spun up both a WebSocket server and HTTP server internally. Additionally, the [React-Swift](https://github.com/jhavl/react-swift.git) page needed to be modified to account for these changes. The modifications are described later in this document.

## Setup

Setting up the repo involves setting paths to dependencies, cloning dependencies, and creating conda environments used during the build process. The [setup.sh](scripts/setup.sh) implements this. Build settings such as dependency paths are stored in the `./swift-wasm-test/conf` folder to be used by other scripts.

```sh
# Dependencies needed for setup process
sudo apt install git
sudo apt install curl
sudo apt install cmake
sudo apt install lbzip2

# Clone this repo
git clone https://github.com/mbatc/swift-wasm-test.git

# Install micromamba (if you haven't already)
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
# You'll need to restart your terminal after installing micromamba

# Run the swift-wasm-test setup script to clone dependencies and setup
# environments used for building the site. If using custom paths for cloned repos
# '~' does not work correctly. You must enter the entire path.
./swift-wasm-test/scripts/setup.sh
```

## Building

Once the project has been setup by running the [setup.sh](scripts/setup.sh) script. You can build everything by running the [build.sh](scripts/build.sh)

```sh
./swift-wasm-test/scripts/build.sh
```

The key steps performed by the build script are,

### 1. Export swift recipe.yaml

The [template recipe](recipes/swift-sim/recipe.yaml.in) (recipe.yaml.in) is exported to `recipes/swift-sim/recipe.yaml` with the `SWIFT_DIR` and `BUILD_NUMBER` variables evaluated. This maps the source path to the local `Swift` repository configure in Setup, and increments the build number in the recipe so that the new package is installed correctly later in the build process.

### 2. Build swift python package

Using the recipe exported in the previous step, `builder.py` from [Emscripten Forge](https://github.com/emscripten-forge/recipes.git) is used to build the Swift python package.

This step is performed within the `Emscripten Forge` conda environment.

### 3. Build react-swift

The build script installs react-swift dependencies and builds the package using using npm. I've found that node v16 is the most compatible with Swift. This is installed to the `react-swift` environment during setup.

This step is performed within the `React Swift` conda environment.

### 3. Build next-swift

This step runs the build procesd for `next-swift` which exports the react app as a static html page the the `swift/out` folder the Swift repository.

For this step, the `NEXT_SWIFT_BASE_PATH` environment variable is used in `next.config.js` to override the base path of the exported site. If the web page is not hosted on the root of the server, then you may need to set this to the prefix used in the URL. For example, the github.io page would use `NEXT_SWIFT_BASE_PATH=/swift-wasm-test/swift`

### 4. Install and Pack

This step installs the Swift python package, `swift-sim` to the web environment and then uses `empack` to export the web environment to the `./dist` directory.

The Web page in [site](./site/) and next-swift built in the previous step are then copied to `./dist`. The `dist` folder is then ready to be hosted on a server.

# Swift Modifications

