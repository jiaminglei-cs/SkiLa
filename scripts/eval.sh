# #!/usr/bin/env bash
# set -euo pipefail

# # Example evaluation script for SkiLa with VLMEvalKit.
# # Usage:
# #   MODEL_PATH=/path/to/your/skila/checkpoint \
# #   WORK_DIR=./outputs/vlmeval \
# #   bash scripts/eval_vlmevalkit_example.sh

# MODEL_PATH="${MODEL_PATH:-/lllidy/lllidy/Projects/SkiLa/SkiLa-7B}"

# # Optional overrides.
# VLM_EVAL_DIR="${VLM_EVAL_DIR:-./VLMEvalKit}"
# WORK_DIR="${WORK_DIR:-./outputs/vlmeval}"
# MODEL_NAME="${MODEL_NAME:-SkiLa}"

# # Datasets highlighted in the paper table.
# # Depending on your local VLMEvalKit version, dataset names may differ.
# DATASETS="${DATASETS:-CVBench_2D CVBench_3D}"

# cd "$VLM_EVAL_DIR"

# python run.py \
#   --model "$MODEL_NAME" \
#   --model-path "$MODEL_PATH" \
#   --data $DATASETS \
#   --work-dir "$WORK_DIR"


#!/usr/bin/env bash
set -euo pipefail

# 完整 VLMEvalKit evaluation 脚本
CONFIG_JSON="${CONFIG_JSON:-/lllidy/lllidy/Projects/SkiLa/SkiLa-7B/config_skila.json}"
VLM_EVAL_DIR="${VLM_EVAL_DIR:-/lllidy/lllidy/Projects/SkiLa/VLMEvalKit}"

cd "$VLM_EVAL_DIR"

# 只使用 --config，不传 --model 或 --data
python run.py --config "$CONFIG_JSON"