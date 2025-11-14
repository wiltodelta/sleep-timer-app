#!/bin/bash

APP_NAME="Sleep Timer"
BUNDLE_ID="com.sleeptimer.app"
BUILD_DIR=".build/release"
APP_DIR="$APP_NAME.app"

echo "Building Sleep Timer for release..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Creating app bundle..."

# Remove old app if exists
rm -rf "$APP_DIR"

# Create app bundle structure
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy binary
cp "$BUILD_DIR/SleepTimer" "$APP_DIR/Contents/MacOS/SleepTimer"

# Copy icon if it exists
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleExecutable</key>
<string>SleepTimer</string>
<key>CFBundleIdentifier</key>
<string>$BUNDLE_ID</string>
<key>CFBundleName</key>
<string>$APP_NAME</string>
<key>CFBundleVersion</key>
<string>1.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>CFBundleIconFile</key>
<string>AppIcon</string>
<key>CFBundlePackageType</key>
<string>APPL</string>
<key>LSMinimumSystemVersion</key>
<string>13.0</string>
<key>LSUIElement</key>
<true/>
<key>NSHumanReadableCopyright</key>
<string>Copyright © 2025. All rights reserved.</string>
<key>NSAppleEventsUsageDescription</key>
<string>This app needs permission to put your Mac to sleep.</string>
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to detect when you fall asleep.</string>
</dict>
</plist>
EOF

echo "✅ App bundle created successfully: $APP_DIR"

# Remove quarantine attribute if running locally (not in CI)
if [ -z "$CI" ]; then
    echo "🔓 Removing quarantine attribute..."
    xattr -cr "$APP_DIR" 2>/dev/null || true
fi

echo "✅ App is ready to use"

echo ""
echo "To install, drag '$APP_DIR' to your Applications folder or run:"
echo "  mv '$APP_DIR' /Applications/"
echo ""
echo "To run now:"
echo "  open '$APP_DIR'"
