#!/bin/zsh
BINARY_NAME="LayoutSwitcher"
APP_NAME="LinguaSwitch"
VERSION="0.5.4"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
PKG_NAME="${APP_NAME}-${VERSION}.pkg"
PKG_ROOT="/tmp/${APP_NAME}_pkg_root"
PKG_SCRIPTS="/tmp/${APP_NAME}_pkg_scripts"

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

echo "▶ Preparing pkg payload..."
rm -rf "$PKG_ROOT" "$PKG_SCRIPTS"
mkdir -p "$PKG_ROOT/Applications"
mkdir -p "$PKG_SCRIPTS"

cp -r "$APP_BUNDLE" "$PKG_ROOT/Applications/"

echo "▶ Creating postinstall script..."
cat > "$PKG_SCRIPTS/postinstall" << 'SCRIPT'
#!/bin/bash
/usr/bin/xattr -dr com.apple.quarantine /Applications/LinguaSwitch.app
exit 0
SCRIPT
chmod +x "$PKG_SCRIPTS/postinstall"

echo "▶ Building component package..."
pkgbuild \
  --root "$PKG_ROOT" \
  --scripts "$PKG_SCRIPTS" \
  --identifier "com.linguaswitch.app" \
  --version "$VERSION" \
  --install-location "/" \
  "$BUILD_DIR/LinguaSwitch-component.pkg"

echo "▶ Building final product package..."
productbuild \
  --package "$BUILD_DIR/LinguaSwitch-component.pkg" \
  --identifier "com.linguaswitch.app" \
  --version "$VERSION" \
  "$BUILD_DIR/$PKG_NAME"

rm -rf "$PKG_ROOT" "$PKG_SCRIPTS"
rm -f "$BUILD_DIR/LinguaSwitch-component.pkg"

echo ""
echo "✅ $BUILD_DIR/$PKG_NAME"
echo "📦 Двічі клікніть .pkg → macOS Installer Wizard встановить у /Applications"
