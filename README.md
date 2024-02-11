# Swift WASM Test

This repo contains a test web page that hosts the [Swift Robotics Simulator](https://github.com/jhavl/swift) entirely within a browser. The swift python package is cross-compiled to Web Assembly with [Emscripten Forge](https://github.com/emscripten-forge/recipes) and loaded in the browser using [Empack](https://github.com/emscripten-forge/empack) and [PyJS](https://github.com/emscripten-forge/pyjs.git). The Swift python package did have to be modified to work in the Web environment as it spun up both a WebSocket server and HTTP server internally. Additionally, the [React-Swift](https://github.com/jhavl/react-swift.git) page needed to be modified to account for these changes. The modifications are described later in this document.

# Setup

```sh
# Dependencies needed for setup process
sudo apt install git
sude apt install curl

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

# Building



# Swift Modifications


