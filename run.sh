
eval "$(micromamba shell hook --shell bash)"

SCRIPT_DIR=$(dirname "$0")
CANON_SCRIPT_DIR=$(cd "$SCRIPT_DIR"; pwd)

echo $CANON_SCRIPT_DIR

micromamba activate pyjs-code-runner

pyjs_code_runner run script \
  browser-main \
  --conda-env ~/micromamba/envs/pyjs-wasm-env \
  --script swift_test.py \
  --mount $CANON_SCRIPT_DIR/dev:/home/web_user/ \
  --mount /home/michael/micromamba/envs/pyjs-wasm-env/lib/python3.11/site-packages:/lib/python3.11/site-packages \
  --work-dir /home/web_user \
  --host-work-dir $CANON_SCRIPT_DIR/dist \
  --async-main \
  --port 8080 \
  --headless

micromamba deactivate
