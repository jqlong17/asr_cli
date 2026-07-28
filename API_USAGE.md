# API / Agent Usage

This folder is intended to be called by another local AI agent or script.

## Text output

```bash
/absolute/path/to/asr_cli/transcribe /absolute/path/to/audio.mp3 -o /absolute/path/to/result.txt
```

Read `/absolute/path/to/result.txt` as UTF-8 plain text.

## JSON output

```bash
/absolute/path/to/asr_cli/transcribe /absolute/path/to/audio.mp3 --json -o /absolute/path/to/result.json
```

Expected JSON fields:

- `text`: recognized transcript
- `confidence`: fixed confidence value from the current Open Flow CLI
- `language`: detected/default language metadata
- `duration_ms`: ASR inference time in milliseconds after audio conversion

## Direct low-level call

If the caller already has a 16 kHz mono PCM WAV file, it can call the bundled engine directly:

```bash
/absolute/path/to/asr_cli/bin/ofasr transcribe \
  --file /absolute/path/to/input-16k-mono.wav \
  --model /absolute/path/to/asr_cli/model \
  --json
```

For general audio/video files, prefer `transcribe` because it performs audio conversion first.

## Persistent local server

Start the server once:

```bash
/absolute/path/to/asr_cli/serve
```

Then call it through the helper script:

```bash
/absolute/path/to/asr_cli/transcribe-server /absolute/path/to/audio.mp3 -o /absolute/path/to/result.txt
```

The server keeps the ONNX model loaded between requests, which is faster for many short files.

Low-level HTTP calls:

```bash
curl -fsS http://127.0.0.1:8765/health
printf '%s' /absolute/path/to/input-16k-mono.wav \
  | curl -fsS --data-binary @- http://127.0.0.1:8765/transcribe
printf '%s' /absolute/path/to/input-16k-mono.wav \
  | curl -fsS --data-binary @- http://127.0.0.1:8765/transcribe.txt
```
