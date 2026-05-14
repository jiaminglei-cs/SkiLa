# 使用 VLMEvalKit 评测 SkiLa（CVBench 2D / 3D）

> 本文档假设你已经完成 SkiLa 权重准备，并单独克隆了 `VLMEvalKit`。
> 注意：示例命令里的 `/path/to/...` 是占位符，必须替换成你机器上的真实路径。

## 1) 安装与准备

```bash
# 1. 进入 SkiLa 仓库
cd /path/to/SkiLa

# 2. 在 VLMEvalKit 环境内安装
cd /path/to/VLMEvalKit
pip install -e .

# 3. 回到 SkiLa，复制适配器
cd /path/to/SkiLa
bash scripts/setup_vlmevalkit_skila.sh /path/to/VLMEvalKit /path/to/SkiLa-7B
```

## 2) 在 VLMEvalKit 注册 SkiLa

**需要修改配置文件。**

上面的 `setup_vlmevalkit_skila.sh` 已自动完成以下两件事：

1. 在 `vlmeval/vlm/__init__.py` 增加：
   `from .skila.skila import SkiLaChat`
2. 在 `vlmeval/config.py` 的 `supported_VLM` 中注册：
   `'SkiLa': partial(SkiLaChat, model_path='YOUR_SKILA_CKPT')`

如果你想手动改，也可以按以上两处修改。

## 3) 运行 CVBench 2D / 3D

在 `VLMEvalKit` 目录下运行（严格版需先暴露 SkiLa 源码路径）：

```bash
export SKILA_REPO_DIR=/path/to/SkiLa
python run.py \
  --model SkiLa \
  --data CVBench_2D CVBench_3D \
  --work-dir ./outputs/skila_cvbench
```

如果你的 VLMEvalKit 版本数据集命名不同，可先查看：

```bash
python run.py -h
```

或在数据集配置文件中确认 `CVBench` 相关别名。

## 4) 速度优化（参考 CoVT 的评测方式）

如果你看到类似 `551/1438 [44:13:17 ...]` 的速度，通常是因为当前只用了**单进程/单卡串行**推理。

CoVT 官方评测文档给出的建议是：使用 `torchrun`，每张 GPU 起一个 VLM 进程并行推理（适合显存足够时）。

```bash
# 例：8 卡并行（按你的机器调整）
LAUNCHER=torchrun NPROC_PER_NODE=8 \
VLM_EVAL_DIR=/path/to/VLMEvalKit \
MODEL_PATH=/path/to/SkiLa-7B \
bash scripts/eval.sh
```

也可以直接在 VLMEvalKit 目录运行：

```bash
torchrun --nproc-per-node 8 run.py \
  --model SkiLa \
  --model-path /path/to/SkiLa-7B \
  --data CVBench_2D CVBench_3D \
  --work-dir ./outputs/skila_cvbench
```

> 注意：并行加速会按进程数增加显存占用。若 OOM，请先降到 `NPROC_PER_NODE=2` 或 `4`。

## 5) 可选：使用 config JSON 启动

可新建 `config_skila_cvbench.json`：

```json
{
  "model": "SkiLa",
  "data": ["CVBench_2D", "CVBench_3D"],
  "work_dir": "./outputs/skila_cvbench"
}
```

然后：

```bash
python run.py --config config_skila_cvbench.json
```

## 6) 常见问题

- **`Cannot import strict SkiLa model class`**：这是严格版适配器在提示找不到 `src.model.skila`。请先 `export SKILA_REPO_DIR=/path/to/SkiLa`，并确认该目录下有 `src/model/skila.py`。
- **仍看到 `.../vlm/qwen2_vl/model.py` 且 `qwen2_5_vl -> qwen2_vl` 警告**：这表示没有走到 `qwen2_5_vl` 后端，当前结果不可信。请升级/切换到包含 `vlmeval.vlm.qwen2_5_vl` 的 VLMEvalKit 版本，并重新执行 setup。
- **`You set ignore_mismatched_sizes to False` + 大量 `MISSING/UNEXPECTED/MISMATCH`**：通常是 `Qwen2.5-VL` 权重被 `Qwen2-VL` 类加载。不要通过 `ignore_mismatched_sizes` 强行跳过，应保证后端是 `qwen2_5_vl`。
- **`NameError: name 'SkiLaChat' is not defined`**：说明 `vlmeval/config.py` 里有注册项但没有导入。重新运行 setup 脚本会自动补上 `from vlmeval.vlm.skila.skila import SkiLaChat`。
- **`ModuleNotFoundError: No module named 'vlmeval.skila'`**：这是旧版本脚本写入了错误 import。请重新运行 `bash scripts/setup_vlmevalkit_skila.sh <VLMEvalKit路径> <SkiLa模型路径>` 自动修复。
  如果仍报错，请手动执行：`sed -i "/skila\.skila import SkiLaChat/d" <VLMEvalKit路径>/vlmeval/config.py`，再重跑 setup 脚本。
- **报错找不到 `SkiLa`**：检查 `vlmeval/vlm/__init__.py` 与 `vlmeval/config.py` 是否都已修改。
- **模型加载失败**：确认 `model_path` 指向包含 `config.json`、tokenizer、权重文件的目录。
- **`Dataset CVBench_2D/3D is not valid, will be skipped`**：这不是模型报错，而是数据集没有被成功构建。通常有两个原因：
  1) `CVBench_2D` / `CVBench_3D` 在你当前 VLMEvalKit 版本里不是官方注册集；
  2) 运行日志里的数据文件不存在（例如 `/lllidy/LMUData/CVBench_2D.tsv`）。

  处理方式：
  - 确认并创建数据根目录（默认常见为 `<LMUData>/`）；
  - 把 `CVBench_2D.tsv`、`CVBench_3D.tsv` 放到日志提示的目录；
  - 或者在 VLMEvalKit 中把数据集名称改成你版本支持的别名后再运行。
- **显存不足**：在 `supported_VLM` 里传入更保守的生成参数（如 `max_new_tokens`）或降低并发。
