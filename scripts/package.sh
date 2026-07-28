#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(dirname "$ROOT_DIR")"
OUT="${1:-/tmp/asr_cli-package.zip}"

cd "$PROJECT_DIR"
zip -qry "$OUT" "$(basename "$ROOT_DIR")" \
  -x "$(basename "$ROOT_DIR")/.git/*" \
  -x "$(basename "$ROOT_DIR")/.DS_Store"

echo "$OUT"
