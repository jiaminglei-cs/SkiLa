from __future__ import annotations

from typing import List, Optional

from transformers import AutoProcessor

import os
import sys

_SKILA_REPO_DIR = os.getenv("SKILA_REPO_DIR")
if _SKILA_REPO_DIR and _SKILA_REPO_DIR not in sys.path:
    sys.path.insert(0, _SKILA_REPO_DIR)

try:
    from src.model.skila import SkiLa
except Exception as exc:  # pragma: no cover
    raise RuntimeError(
        "Cannot import strict SkiLa model class. Set SKILA_REPO_DIR to your SkiLa repo root "
        "before running VLMEvalKit."
    ) from exc
from vlmeval.vlm.qwen2_5_vl import Qwen2_5VLChat as _BaseQwenChat


class SkiLaChat(_BaseQwenChat):
    """Strict SkiLa backend for VLMEvalKit.

    This adapter forces VLMEvalKit to instantiate the local SkiLa model class,
    rather than plain Qwen2.5-VL.
    """

    INSTALL_REQ = False
    INTERLEAVE = True

    def __init__(self, model_path: str, **kwargs):
        kwargs.setdefault("trust_remote_code", True)
        kwargs.pop("ignore_mismatched_sizes", None)

        # Force VLMEvalKit qwen2_5_vl backend to use SkiLa model class.
        try:
            import vlmeval.vlm.qwen2_5_vl.model as qwen25_model

            qwen25_model.MODEL_CLS = SkiLa
        except Exception as exc:  # pragma: no cover
            raise RuntimeError(
                "Cannot patch vlmeval.vlm.qwen2_5_vl.model.MODEL_CLS to SkiLa. "
                "Please make sure your VLMEvalKit has qwen2_5_vl backend."
            ) from exc

        super().__init__(model_path=model_path, **kwargs)
        self.processor = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)

    def set_max_tokens(self, max_new_tokens: int) -> None:
        self.max_new_tokens = max_new_tokens
        if hasattr(self, "generate_kwargs") and isinstance(self.generate_kwargs, dict):
            self.generate_kwargs["max_new_tokens"] = max_new_tokens

    def generate_inner(
        self,
        message: List[dict],
        dataset: Optional[str] = None,
    ) -> str:
        return super().generate_inner(message=message, dataset=dataset)
