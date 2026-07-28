#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_DIR="$ROOT_DIR/model"
OFASR="$ROOT_DIR/bin/ofasr"

echo "== model registry =="
"$ROOT_DIR/scripts/model_cli" check

echo "== asr model check =="
"$OFASR" check --json --model "$MODEL_DIR"

echo "== cli help =="
"$ROOT_DIR/bin/asr_cli" --help >/dev/null
"$ROOT_DIR/bin/vad_cli" --help >/dev/null
"$ROOT_DIR/bin/tts_cli" --help >/dev/null
"$ROOT_DIR/bin/embed_cli" --help >/dev/null
"$ROOT_DIR/bin/vision_cli" --help >/dev/null
"$ROOT_DIR/bin/route_cli" --help >/dev/null

echo "verify passed"
