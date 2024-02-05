
eval "$(micromamba shell hook --shell bash)"

SCRIPT_DIR=$(dirname "$0")

python -m http.server --directory $SCRIPT_DIR/dist
