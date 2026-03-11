#!/bin/zsh
BINARY_NAME="LayoutSwitcher"
APP_NAME="LinguaSwitch"
VERSION="0.5.0"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_STAGING="/tmp/${APP_NAME}_dmg"

echo "Building release binary..."
swift build -c release

echo "Creating .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"

cp "$BUILD_DIR/$BINARY_NAME" "$CONTENTS/MacOS/$APP_NAME"
cp "Info.plist" "$CONTENTS/Info.plist"
cp "Sources/LayoutSwitcher/Resources/en_words.txt" "$CONTENTS/Resources/"
cp "Sources/LayoutSwitcher/Resources/uk_words.txt" "$CONTENTS/Resources/"

echo "Ad-hoc signing..."
codesign --deep --force --sign - "$APP_BUNDLE"

echo "Creating .dmg..."
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -r "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGING" -ov -format UDZO -o "$BUILD_DIR/$DMG_NAME"

rm -rf "$DMG_STAGING"
echo ""
echo "✅ $BUILD_DIR/$DMG_NAME"
echo "📦 Бета-тестери: right-click → Open при першому запуску"
