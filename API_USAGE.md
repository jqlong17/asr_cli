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
