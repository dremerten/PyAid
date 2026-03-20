#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXT_DIR="$ROOT_DIR/extension"

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Error: node is not installed or not in PATH." >&2
  exit 1
fi

echo "[PyAid] Packaging beta VSIX..."
echo "[PyAid] Extension dir: $EXT_DIR"

cd "$EXT_DIR"

npm install
npm run build
npm run package

LATEST_VSIX="$(ls -t pyaid-*.vsix 2>/dev/null | head -n 1 || true)"
if [[ -z "$LATEST_VSIX" ]]; then
  echo "Error: VSIX package was not created." >&2
  exit 1
fi

echo ""
echo "[PyAid] Package created successfully:"
echo "[PyAid] $EXT_DIR/$LATEST_VSIX"
