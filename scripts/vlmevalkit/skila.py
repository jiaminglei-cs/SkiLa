from __future__ import annotations

from typing import List, Optional

from PIL import Image
from transformers import AutoProcessor

from vlmeval.vlm.qwen2_vl import Qwen2VLChat


class SkiLaChat(Qwen2VLChat):
    """SkiLa wrapper for VLMEvalKit.

    SkiLa-7B is based on Qwen2.5-VL and can reuse Qwen2VLChat with a
    dedicated class name for model registration.
    """

    INSTALL_REQ = False
    INTERLEAVE = True

    def __init__(self, model_path: str, **kwargs):
        super().__init__(model_path=model_path, **kwargs)
        self.processor = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)

    def set_max_tokens(self, max_new_tokens: int) -> None:
        self.kwargs["max_new_tokens"] = max_new_tokens

    def generate_inner(self, message: List[dict], dataset: Optional[str] = None) -> str:
        # Reuse inherited Qwen2-VL generation logic for image-text chat.
        return super().generate_inner(message=message, dataset=dataset)
