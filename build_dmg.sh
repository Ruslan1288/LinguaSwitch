#!/bin/zsh
BINARY_NAME="LayoutSwitcher"
APP_NAME="LinguaSwitch"
VERSION="0.5.0"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_STAGING="/tmp/${APP_NAME}_dmg"

echo "▶ Cleaning previous build..."
swift package clean

echo "▶ Building release binary..."
swift build -c release

echo "▶ Creating .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"

# Binary
cp "$BUILD_DIR/$BINARY_NAME" "$CONTENTS/MacOS/$APP_NAME"

# Info.plist
cp "Info.plist" "$CONTENTS/Info.plist"

# Resource bundles — Bundle.module looks at Bundle.main.bundleURL (= .app root)
cp -r "$BUILD_DIR/LayoutSwitcher_LayoutSwitcher.bundle" "$APP_BUNDLE/"
cp -r "$BUILD_DIR/GRDB_GRDB.bundle" "$APP_BUNDLE/"

# Remove ru_words.txt from resource bundle (not needed)
rm -f "$APP_BUNDLE/LayoutSwitcher_LayoutSwitcher.bundle/ru_words.txt"

echo "▶ Fixing permissions..."
chmod -R a+rX "$APP_BUNDLE"
chmod +x "$CONTENTS/MacOS/$APP_NAME"

echo "▶ Ad-hoc signing..."
codesign --deep --force --sign - "$APP_BUNDLE"

echo "▶ Creating .dmg..."
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -r "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGING" -ov -format UDZO -o "$BUILD_DIR/$DMG_NAME"

rm -rf "$DMG_STAGING"
echo ""
echo "✅ $BUILD_DIR/$DMG_NAME"
echo "📦 Бета-тестери: right-click → Open при першому запуску"
