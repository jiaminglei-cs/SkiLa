# 使用 VLMEvalKit 评测 SkiLa（CVBench 2D / 3D）

> 本文档假设你已经完成 SkiLa 权重准备，并单独克隆了 `VLMEvalKit`。

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

在 `VLMEvalKit` 目录下运行：

```bash
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

## 4) 可选：使用 config JSON 启动

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

## 5) 常见问题

- **报错找不到 `SkiLa`**：检查 `vlmeval/vlm/__init__.py` 与 `vlmeval/config.py` 是否都已修改。
- **模型加载失败**：确认 `model_path` 指向包含 `config.json`、tokenizer、权重文件的目录。
- **显存不足**：在 `supported_VLM` 里传入更保守的生成参数（如 `max_new_tokens`）或降低并发。
