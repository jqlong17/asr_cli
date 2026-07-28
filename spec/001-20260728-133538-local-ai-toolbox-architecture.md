# 001 2026-07-28 13:35:38 Local AI Toolbox Architecture

## Background

`asr_cli` currently works because it is intentionally small and operationally boring: a bundled ffmpeg binary, a native `ofasr` binary, and a SenseVoice ONNX model directory. It can be called by other local AI agents without Python, PyTorch, ModelScope, CUDA, or a heavy service stack.

The next product direction is to keep that shape while expanding into a small family of local model tools:

- `asr_cli`: speech to text, current mainline.
- `vad_cli`: voice activity detection and segmentation.
- `tts_cli`: small text to speech, likely Kokoro first.
- `embed_cli`: text embeddings and local retrieval.
- `vision_cli`: image embeddings and image/text retrieval.
- `route_cli`: small local intent routing and tool selection.

The core risk is turning a good small tool into a heavy "AI distribution". The architecture must preserve the current advantage: small packages, fast startup, offline operation, predictable CLI/server contracts, and optional model packs.

## Goals

- Create a long-term local AI toolbox architecture that keeps `asr_cli` small and fast by default.
- Preserve the existing `transcribe`, `serve`, and `transcribe-server` entrypoints.
- Add a repo-level model registry so each capability can declare required files, package size expectations, runtime type, and default install path.
- Add a scripts/docs scaffold for packaging and verification without bundling every future model into the base package.
- Define stable public contracts for future `vad_cli`, `tts_cli`, `embed_cli`, `vision_cli`, and `route_cli`.
- Make Phase 1 implementable without introducing new heavy dependencies or downloading large models.

## Non-Goals

- Do not bundle Kokoro, MiniLM, MobileCLIP/Nomic Vision, or route LLM models in this pass.
- Do not replace the current SenseVoice ONNX ASR backend.
- Do not add Python, PyTorch, FunASR, CosyVoice, or a full model-serving stack.
- Do not implement model-level hotword/contextual biasing in this pass.
- Do not rename the GitHub repository or remove the compatibility scripts.

## CLI / Server Contract

All tools should converge on this shape:

```bash
<tool> check [--json]
<tool> <verb> <input> [-o output] [--json]
<tool> serve [--addr 127.0.0.1:PORT]
```

All local servers should expose:

```text
GET  /health
POST /run
POST /run.txt
```

Compatibility aliases are allowed when they make a tool more natural:

- `asr_cli transcribe`
- `vad_cli segment`
- `tts_cli speak`
- `embed_cli embed`
- `vision_cli embed`
- `route_cli route`

JSON response shape:

```json
{
  "tool": "asr_cli",
  "model": "sensevoice-small-onnx",
  "duration_ms": 224,
  "output": {},
  "meta": {}
}
```

## Implementation Plan

1. Add documentation:
   - `docs/LOCAL_AI_TOOLBOX_ROADMAP.md`
   - `spec/README.md`
   - this spec file.
2. Add configuration scaffold:
   - `configs/model_registry.json`
   - keep model packs optional and separately listed.
3. Add script scaffold:
   - `scripts/verify.sh`
   - `scripts/package.sh`
   - `scripts/model_cli`
4. Preserve current compatibility entrypoints:
   - `transcribe`
   - `serve`
   - `transcribe-server`
5. Add placeholder CLI wrappers for future tools only if they fail clearly with "model not installed / tool not implemented yet"; do not fake working model outputs.
6. Verify current ASR path still works:
   - model check ready.
   - one short transcription through direct CLI.
   - server health and server transcription.
7. Update review notes with actual implemented files and verification results.

## Acceptance Checks

- `spec/README.md` and this spec exist before implementation changes.
- `docs/LOCAL_AI_TOOLBOX_ROADMAP.md` describes medium/long-term direction and prioritizes small/fast/effective over feature breadth.
- `configs/model_registry.json` lists planned tool/model packs without bundling new heavy models.
- Existing ASR commands still work:
  - `./transcribe <audio> -o <txt>`
  - `./serve`
  - `./transcribe-server <audio> -o <txt>`
- `scripts/verify.sh` can run local checks without requiring unavailable optional model packs.
- `git diff --check` passes.

## Review Notes

- Added `docs/LOCAL_AI_TOOLBOX_ROADMAP.md` with the medium/long-term direction for `asr_cli`, `vad_cli`, `tts_cli`, `embed_cli`, `vision_cli`, and `route_cli`.
- Added `configs/model_registry.json` with the installed SenseVoice ASR pack and planned optional model packs. No new heavy model was bundled.
- Added `scripts/model_cli`, `scripts/verify.sh`, and `scripts/package.sh`.
- Added unified `bin/asr_cli` wrapper while preserving `transcribe`, `serve`, and `transcribe-server`.
- Added planned-status wrappers for `bin/vad_cli`, `bin/tts_cli`, `bin/embed_cli`, `bin/vision_cli`, and `bin/route_cli`. They report missing model packs and do not produce fake outputs.
- `./scripts/verify.sh` passed.
- `./scripts/model_cli list` reports installed ASR and planned future tools.
- `./bin/vad_cli check --json` returns `ready:false` and exits non-zero as intended.
- `./bin/asr_cli transcribe /tmp/asr_cli_phase1_20s.mp3 -o /tmp/asr_cli_phase1_20s.txt` succeeded on a 20-second sample.
- `./serve --addr 127.0.0.1:18766` plus `./transcribe-server ... --addr 127.0.0.1:18766` succeeded; server request took about 0.28s for the test segment after the model was already loaded.
