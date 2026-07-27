# asr_cli

一个可以直接发给别人使用的本地音频转文字工具包。

## 下载

请从 GitHub Releases 下载 `asr_cli.zip`。完整压缩包里已经包含 SenseVoice Small ONNX 模型，不需要使用者再下载模型。

源码仓库为了避开 GitHub 的单文件大小限制，不直接提交 `model/model.onnx`；可运行的完整版本以 Release 附件为准。

它包含：

- `bin/ofasr`：Open Flow 抽出的本地 SenseVoice ASR 命令行工具
- `bin/ffmpeg`：音频格式转换工具
- `model/`：已打包好的 SenseVoice Small ONNX 模型，不需要使用者再下载
- `transcribe`：推荐入口脚本，支持 mp3 / wav / m4a / mp4 / mov 等常见音视频输入

## 使用方式

进入工具目录：

```bash
cd ~/Desktop/asr_cli
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

## 给其他 AI 调用

最简单的调用方式：

```bash
/path/to/asr_cli/transcribe /path/to/audio.mp3 -o /path/to/result.txt
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
