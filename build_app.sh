#!/usr/bin/env bash
# Build SbxMonitor and assemble a runnable .app bundle in dist/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

CONFIG="${CONFIG:-release}"
APP_NAME="SbxMonitor"
APP="dist/${APP_NAME}.app"

echo "==> Building ($CONFIG)…"
swift build -c "$CONFIG"

BIN=".build/${CONFIG}/${APP_NAME}"
if [[ ! -x "$BIN" ]]; then
  echo "Build produced no executable at $BIN" >&2
  exit 1
fi

echo "==> Assembling ${APP}…"
rm -rf "$APP"
mkdir -p "${APP}/Contents/MacOS" "${APP}/Contents/Resources"
cp "$BIN" "${APP}/Contents/MacOS/${APP_NAME}"
cp Resources/Info.plist "${APP}/Contents/Info.plist"

if [[ -f Resources/AppIcon.icns ]]; then
  cp Resources/AppIcon.icns "${APP}/Contents/Resources/AppIcon.icns"
  /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "${APP}/Contents/Info.plist" 2>/dev/null || true
fi

echo "==> Ad-hoc signing…"
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || \
  echo "  (codesign skipped — the app still runs locally)"

echo "==> Done: ${APP}"
echo "    Run with: open ${APP}"
