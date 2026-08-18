#!/bin/sh
# Builds a Release LookMD.app and packages it into a distributable DMG.
# Ad-hoc signed (no Developer ID) — recipients need one right-click > Open
# on first launch, see README.

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="$ROOT/build"
DMG_STAGING="$BUILD_DIR/dmg-staging"
APP_NAME="LookMD.app"
VOLUME_NAME="LookMD"
DMG_PATH="$BUILD_DIR/LookMD.dmg"

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building Release"
rm -rf "$BUILD_DIR/Build"
xcodebuild -project LookMD.xcodeproj -scheme LookMD -configuration Release \
  -derivedDataPath "$BUILD_DIR" build

APP_SRC="$BUILD_DIR/Build/Products/Release/$APP_NAME"
if [ ! -d "$APP_SRC" ]; then
  echo "error: built app not found at $APP_SRC"
  exit 1
fi

echo "==> Staging DMG contents"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
ditto "$APP_SRC" "$DMG_STAGING/$APP_NAME"
ln -s /Applications "$DMG_STAGING/Applications"

echo "==> Creating DMG"
rm -f "$DMG_PATH"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH"

echo "==> Done: $DMG_PATH"
