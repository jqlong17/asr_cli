# Local AI CLI Toolbox Roadmap

## Product Thesis

The project should remain a set of small, fast, offline local model tools that other AI agents can call through CLI or local HTTP. The winning property is not maximum model breadth; it is low-friction execution:

```text
download -> unzip -> run a command -> get useful output
```

The default package must stay small. Heavy models are optional packs, never mandatory.

## Core Principles

- Small first: keep the default package close to the current `asr_cli` size and behavior.
- Fast first: prefer ONNX, GGUF, sherpa-onnx, native binaries, and reusable local servers over Python-heavy stacks.
- Useful quality floor: do not add tiny models that are too weak for practical use.
- Optional model packs: ship `core` separately from ASR/VAD/TTS/embed/vision/route model packs.
- Stable contracts: every tool should expose CLI and optional local server behavior.
- No fake capabilities: if a model is not installed, fail clearly and tell the caller what is missing.
- Agent-friendly output: plain text for simple flows, JSON for automation.

## Tool Family

### asr_cli

Purpose: speech to text.

Current backend:

```text
ffmpeg -> 16 kHz mono WAV -> SenseVoice ONNX -> Rust/ONNX Runtime -> CTC decode
```

Keep this as the default mainline. It is the reference for the rest of the toolbox.

Near-term improvements:

- keep `serve` model reuse.
- support VAD segment inputs.
- keep plain text and JSON outputs stable.

### vad_cli

Purpose: speech detection, long audio segmentation, silence skipping.

Preferred first backend:

```text
Silero VAD ONNX
```

Why first:

- tiny model footprint.
- directly improves current ASR.
- useful for long recordings and real-time capture.

Initial commands:

```bash
vad_cli check --json
vad_cli segment audio.mp3 -o segments.json
vad_cli split audio.mp3 -o chunks/
```

### tts_cli

Purpose: text to speech.

Preferred first backend:

```text
Kokoro ONNX through sherpa-onnx or native wrapper
```

Keep it separate from ASR. Do not bring CosyVoice into the default package because the model and Python stack are too heavy for this project's core identity.

Initial commands:

```bash
tts_cli speak "hello" -o hello.wav
tts_cli voices
tts_cli serve
```

### embed_cli

Purpose: text embedding and local retrieval.

Preferred first backend:

```text
MiniLM ONNX
```

Alternative medium-term backend:

```text
Nomic Embed Text
```

Initial commands:

```bash
embed_cli embed "query" -o vector.json
embed_cli index docs/ -o index/
embed_cli search "query" index/
```

### vision_cli

Purpose: image embedding and image/text retrieval.

Preferred candidates:

```text
MobileCLIP
Nomic Embed Vision
```

Do not start with a large vision-language generator. Retrieval/embedding is smaller and more aligned with the project.

Initial commands:

```bash
vision_cli embed image.png -o image.vector.json
vision_cli index screenshots/ -o image_index/
vision_cli search "chart screenshot" image_index/
```

### route_cli

Purpose: local intent routing and tool selection.

Preferred candidates:

```text
SmolLM2 135M/360M GGUF
Qwen2.5 0.5B GGUF
```

This is not a chat model. It should output constrained JSON for local tool selection.

Initial command:

```bash
route_cli route "transcribe this meeting audio"
```

Example output:

```json
{
  "tool": "asr_cli",
  "command": "transcribe",
  "confidence": 0.92
}
```

## Packaging Strategy

Use separate release assets:

```text
core-macos-arm64.zip
asr-sensevoice-small.zip
vad-silero.zip
tts-kokoro.zip
embed-minilm.zip
vision-mobileclip.zip
route-smollm2-135m-q4.zip
```

The current full `asr_cli.zip` remains valid as an ASR-first distribution. Future releases can add a smaller core package once multiple tools exist.

## Model Registry

Every model pack should be declared in `configs/model_registry.json` with:

- id
- tool
- backend
- platform
- required files
- optional files
- install directory
- size class
- status

## Roadmap

### Phase 1: Stabilize asr_cli as the reference tool

- Preserve current ASR CLI/server behavior.
- Add specs, roadmap, model registry, packaging scripts.
- Add verification script for local ASR.

### Phase 2: Add vad_cli

- Add Silero VAD ONNX model pack.
- Implement `segment` and `split`.
- Let ASR consume segment JSON for long files.

### Phase 3: Add tts_cli and embed_cli

- Add Kokoro as optional TTS pack.
- Add MiniLM as optional text embedding pack.
- Keep both separate from the ASR base package.

### Phase 4: Add vision_cli and route_cli

- Add image embeddings first, not full visual reasoning.
- Add route CLI as constrained JSON tool selector.

### Phase 5: Unified local server

- Keep individual `serve` commands.
- Optionally add `local_ai serve` that routes to installed tools.

## Definition of Done

Each new tool is accepted only when it has:

- clear model pack declaration.
- `check` command.
- one practical command that produces useful output.
- optional server endpoint, if reuse materially improves speed.
- verification script coverage.
- documentation with failure modes.
