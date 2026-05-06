#!/usr/bin/env bash
set -euo pipefail

# Evaluate SkiLa with VLMEvalKit on CVBench 2D/3D.
# Usage:
#   VLM_EVAL_DIR=/path/to/VLMEvalKit \
#   MODEL_PATH=/path/to/SkiLa-7B \
#   bash scripts/eval.sh

VLM_EVAL_DIR="${VLM_EVAL_DIR:-}"
MODEL_PATH="${MODEL_PATH:-}"
WORK_DIR="${WORK_DIR:-./outputs/skila_cvbench}"
MODEL_NAME="${MODEL_NAME:-SkiLa}"
DATASETS="${DATASETS:-CVBench_2D CVBench_3D}"

if [[ -z "$VLM_EVAL_DIR" || -z "$MODEL_PATH" ]]; then
  echo "[Error] Please set VLM_EVAL_DIR and MODEL_PATH first."
  exit 1
fi

cd "$VLM_EVAL_DIR"

python run.py \
  --model "$MODEL_NAME" \
  --model-path "$MODEL_PATH" \
  --data $DATASETS \
  --work-dir "$WORK_DIR"
