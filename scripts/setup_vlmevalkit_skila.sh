#!/usr/bin/env bash
set -euo pipefail

# Register SkiLa into an existing VLMEvalKit checkout.
# Usage:
#   bash scripts/setup_vlmevalkit_skila.sh /path/to/VLMEvalKit /path/to/SkiLa-7B

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 /path/to/VLMEvalKit /path/to/SkiLa-7B"
  exit 1
fi

VLM_EVAL_DIR="$1"
MODEL_PATH="$2"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "$VLM_EVAL_DIR/vlmeval" ]]; then
  echo "[Error] $VLM_EVAL_DIR does not look like a VLMEvalKit repo (missing vlmeval/)."
  exit 1
fi

mkdir -p "$VLM_EVAL_DIR/vlmeval/vlm/skila"
cp "$REPO_ROOT/scripts/vlmevalkit/skila.py" "$VLM_EVAL_DIR/vlmeval/vlm/skila/skila.py"

echo "[Info] Copied SkiLa adapter to VLMEvalKit."

python - "$VLM_EVAL_DIR" "$MODEL_PATH" <<'PY'
from pathlib import Path
import sys

repo = Path(sys.argv[1])
model_path = sys.argv[2]

# 1) Ensure vlmeval/vlm/__init__.py imports SkiLaChat
init_py = repo / "vlmeval" / "vlm" / "__init__.py"
import_line = "from .skila.skila import SkiLaChat"
text = init_py.read_text(encoding="utf-8")
if import_line not in text:
    text += "\n" + import_line + "\n"
    init_py.write_text(text, encoding="utf-8")

# 2) Ensure vlmeval/config.py imports partial + SkiLaChat and registers supported_VLM entry
config_py = repo / "vlmeval" / "config.py"
text = config_py.read_text(encoding="utf-8")

if "from functools import partial" not in text:
    text = "from functools import partial\n" + text

if import_line not in text:
    # Insert after other vlm imports when possible.
    marker = "from vlmeval.vlm import *"
    if marker in text:
        text = text.replace(marker, marker + "\n" + import_line, 1)
    else:
        text = import_line + "\n" + text

entry = f"    'SkiLa': partial(SkiLaChat, model_path='{model_path}'),"
if "'SkiLa': partial(SkiLaChat" not in text:
    marker = "supported_VLM = {"
    if marker not in text:
        raise RuntimeError("Cannot find supported_VLM dict in vlmeval/config.py")
    text = text.replace(marker, marker + "\n" + entry, 1)

config_py.write_text(text, encoding="utf-8")
print("[Info] Registered SkiLa in vlmeval/config.py and vlmeval/vlm/__init__.py")
PY

echo "[Done] You can now run scripts/eval.sh with MODEL_PATH and VLM_EVAL_DIR."
