# asr_cli

一个可以直接发给别人使用的本地音频转文字工具包。

长期方向是一个小而快的本地 AI CLI 工具箱，但当前主线仍然是 `asr_cli`：

```text
asr_cli       语音转文字，当前可用
vad_cli       人声检测/切段，计划中
tts_cli       小型 TTS，计划中
embed_cli     文本向量/本地检索，计划中
vision_cli    图片向量/图片检索，计划中
route_cli     小模型意图识别/工具路由，计划中
```

设计原则见 [`docs/LOCAL_AI_TOOLBOX_ROADMAP.md`](docs/LOCAL_AI_TOOLBOX_ROADMAP.md)。所有非 ASR 能力都会作为可选模型包推进，不会默认塞进主包。

## 下载

请从 GitHub Releases 下载 `asr_cli.zip`。完整压缩包里已经包含 SenseVoice Small ONNX 模型，不需要使用者再下载模型。

源码仓库为了避开 GitHub 的单文件大小限制，不直接提交 `model/model.onnx`；可运行的完整版本以 Release 附件为准。

它包含：

- `bin/ofasr`：Open Flow 抽出的本地 SenseVoice ASR 命令行工具
- `bin/ffmpeg`：音频格式转换工具
- `model/`：已打包好的 SenseVoice Small ONNX 模型，不需要使用者再下载
- `transcribe`：推荐入口脚本，支持 mp3 / wav / m4a / mp4 / mov 等常见音视频输入
- `serve`：常驻本机 HTTP 服务，启动后模型只加载一次
- `transcribe-server`：连接 `serve` 的客户端脚本，适合批量短音频
- `bin/asr_cli`：统一 ASR 命令入口，兼容现有脚本
- `bin/vad_cli` / `bin/tts_cli` / `bin/embed_cli` / `bin/vision_cli` / `bin/route_cli`：未来工具入口，目前只提供明确的 planned/check 状态，不伪造结果

## 使用方式

进入工具目录：

```bash
cd /path/to/asr_cli
```

直接输出到终端：

```bash
./transcribe /path/to/audio.mp3
```

输出到文本文件：

```bash
./transcribe /path/to/audio.mp3 -o /path/to/result.txt
```

输出 JSON：

```bash
./transcribe /path/to/audio.mp3 --json -o /path/to/result.json
```

也可以使用统一入口：

```bash
./bin/asr_cli transcribe /path/to/audio.mp3 -o /path/to/result.txt
./bin/asr_cli check --json
```

## 常驻服务模式

如果要连续转写很多短音频，先启动服务：

```bash
./serve
```

另开一个终端，通过服务转写：

```bash
./transcribe-server /path/to/audio.mp3 -o /path/to/result.txt
```

服务默认监听 `127.0.0.1:8765`，可以这样改端口：

```bash
./serve --addr 127.0.0.1:8766
./transcribe-server /path/to/audio.mp3 --addr 127.0.0.1:8766 -o result.txt
```

## 给其他 AI 调用

最简单的调用方式：

```bash
/path/to/asr_cli/transcribe /path/to/audio.mp3 -o /path/to/result.txt
```

批量调用时，推荐先启动服务，再调用：

```bash
/path/to/asr_cli/serve
/path/to/asr_cli/transcribe-server /path/to/audio.mp3 -o /path/to/result.txt
```

返回纯文本时，结果文件就是转写文本。

返回 JSON 时，结构类似：

```json
{
  "text": "转写结果",
  "confidence": 0.95,
  "language": "zh",
  "duration_ms": 1234
}
```

## 环境要求

- 推荐：macOS Apple Silicon（M1/M2/M3/M4）
- 不需要联网
- 不需要单独下载模型
- 不需要安装 Python
- 第一次运行如果 macOS 提示安全拦截，可以在终端执行：

```bash
xattr -dr com.apple.quarantine /path/to/asr_cli
chmod +x /path/to/asr_cli/transcribe /path/to/asr_cli/bin/ofasr /path/to/asr_cli/bin/ffmpeg
```

## 注意

- 这个包当前是 macOS arm64 版本。
- 长音频可以直接传入，但一次性转写非常长的文件可能耗时较久。
- 底层 ASR 更偏中文语音；中英混杂也能处理，但人名、机构名、英文缩写建议人工复核。
