import os
from datasets import load_dataset

# 指定下载目录
DATA_DIR = "/lllidy/lllidy/Projects/SkiLa/datasets/CVBench"
os.makedirs(DATA_DIR, exist_ok=True)

# 设置 Hugging Face 数据集缓存目录
os.environ["HF_DATASETS_CACHE"] = DATA_DIR

# 下载 CV-Bench 全部 2D+3D
# print("Downloading CV-Bench dataset (2D+3D)...")
# cv_bench = load_dataset("nyu-visionx/CV-Bench")
cv_bench_2d = load_dataset("nyu-visionx/CV-Bench", "2D")

# 下载 3D
cv_bench_3d = load_dataset("nyu-visionx/CV-Bench", "3D")