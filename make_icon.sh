#!/usr/bin/env bash
# Generate Resources/AppIcon.icns from the programmatic icon.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

MASTER="build/AppIcon-1024.png"
ICONSET="build/AppIcon.iconset"

mkdir -p build
echo "==> Rendering master 1024x1024 icon…"
swift Tools/make_icon.swift "$MASTER"

echo "==> Building iconset…"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

render() { # size filename
  sips -z "$1" "$1" "$MASTER" --out "$ICONSET/$2" >/dev/null
}

render 16   icon_16x16.png
render 32   icon_16x16@2x.png
render 32   icon_32x32.png
render 64   icon_32x32@2x.png
render 128  icon_128x128.png
render 256  icon_128x128@2x.png
render 256  icon_256x256.png
render 512  icon_256x256@2x.png
render 512  icon_512x512.png
cp "$MASTER" "$ICONSET/icon_512x512@2x.png"

echo "==> Converting to .icns…"
mkdir -p Resources
iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns

echo "==> Done: Resources/AppIcon.icns"
ls -lh Resources/AppIcon.icns
