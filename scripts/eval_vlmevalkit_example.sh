#!/usr/bin/env bash
set -euo pipefail

# Robust evaluation launcher for SkiLa + VLMEvalKit.
# It auto-detects whether your local VLMEvalKit uses:
#   A) --model/--model-path style, or
#   B) --config style.

VLM_EVAL_DIR="${VLM_EVAL_DIR:-./VLMEvalKit}"
WORK_DIR="${WORK_DIR:-./outputs/vlmeval}"
MODEL_NAME="${MODEL_NAME:-SkiLa}"
DATASETS="${DATASETS:-CVBench_2D CVBench_3D}"
PYTHON_BIN="${PYTHON_BIN:-python}"

if [[ ! -d "$VLM_EVAL_DIR" ]]; then
  echo "[ERR] VLM_EVAL_DIR not found: $VLM_EVAL_DIR" >&2
  exit 1
fi

cd "$VLM_EVAL_DIR"
HELP_TEXT="$($PYTHON_BIN run.py --help 2>&1 || true)"

if grep -q -- "--model-path" <<<"$HELP_TEXT"; then
  : "${MODEL_PATH:?Please set MODEL_PATH to your local SkiLa checkpoint path}"
  echo "[INFO] Detected --model-path interface"
  exec "$PYTHON_BIN" run.py \
    --model "$MODEL_NAME" \
    --model-path "$MODEL_PATH" \
    --data $DATASETS \
    --work-dir "$WORK_DIR"
fi

if grep -q -- "--config" <<<"$HELP_TEXT"; then
  : "${MODEL_CONFIG:?Please set MODEL_CONFIG to your VLMEvalKit model config file path}"
  echo "[INFO] Detected --config interface"
  exec "$PYTHON_BIN" run.py \
    --config "$MODEL_CONFIG" \
    --data $DATASETS \
    --work-dir "$WORK_DIR"
fi

echo "[ERR] Cannot detect supported interface from 'python run.py --help'." >&2
echo "[ERR] Please run manually: python run.py --help" >&2
exit 2
