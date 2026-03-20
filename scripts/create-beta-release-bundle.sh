#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXT_DIR="$ROOT_DIR/extension"
ARTIFACTS_DIR="$ROOT_DIR/release-artifacts"
STAMP="$(date +%Y%m%d-%H%M%S)"

if ! command -v zip >/dev/null 2>&1; then
  echo "Error: zip is required but not installed." >&2
  exit 1
fi

"$ROOT_DIR/scripts/package-beta-vsix.sh"

LATEST_VSIX="$(ls -t "$EXT_DIR"/pyaid-*.vsix 2>/dev/null | head -n 1 || true)"
if [[ -z "$LATEST_VSIX" ]]; then
  echo "Error: could not find generated VSIX in $EXT_DIR" >&2
  exit 1
fi

VSIX_BASENAME="$(basename "$LATEST_VSIX")"
BUNDLE_NAME="pyaid-beta-bundle-${STAMP}"
STAGING_DIR="$ARTIFACTS_DIR/$BUNDLE_NAME"
ZIP_PATH="$ARTIFACTS_DIR/${BUNDLE_NAME}.zip"

mkdir -p "$STAGING_DIR"

cp "$LATEST_VSIX" "$STAGING_DIR/"
cp "$ROOT_DIR/PyAid_BETA_Setup_Instructions.md" "$STAGING_DIR/"
cp "$ROOT_DIR/scripts/pyaid-beta-onboarding.sh" "$STAGING_DIR/"
cp "$ROOT_DIR/scripts/pyaid-beta-onboarding.ps1" "$STAGING_DIR/"

if command -v sha256sum >/dev/null 2>&1; then
  (cd "$STAGING_DIR" && sha256sum "$VSIX_BASENAME" PyAid_BETA_Setup_Instructions.md pyaid-beta-onboarding.sh pyaid-beta-onboarding.ps1 > SHA256SUMS.txt)
elif command -v shasum >/dev/null 2>&1; then
  (cd "$STAGING_DIR" && shasum -a 256 "$VSIX_BASENAME" PyAid_BETA_Setup_Instructions.md pyaid-beta-onboarding.sh pyaid-beta-onboarding.ps1 > SHA256SUMS.txt)
fi

rm -f "$ZIP_PATH"
(
  cd "$ARTIFACTS_DIR"
  zip -r "${BUNDLE_NAME}.zip" "$BUNDLE_NAME" >/dev/null
)

echo ""
echo "[PyAid] Release bundle created:"
echo "[PyAid] $ZIP_PATH"
echo ""
echo "[PyAid] Contents:"
ls -1 "$STAGING_DIR"
echo ""
echo "[PyAid] Suggested GitHub release upload:"
echo "gh release create <tag> \"$ZIP_PATH\" --title \"PyAid Beta <tag>\" --notes \"Beta build: $VSIX_BASENAME\""
