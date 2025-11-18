#!/bin/bash

# Ensure output directory exists
mkdir -p Resources

# Create temporary .xcassets structure
ASSETS_DIR="TemporaryAssets.xcassets"
ICONSET_DIR="$ASSETS_DIR/AppIcon.appiconset"

rm -rf "$ASSETS_DIR"
mkdir -p "$ICONSET_DIR"

# 1. Define Source Files from your exports
# Adjust filenames if needed based on exact names in 'icon Exports'
LIGHT_ICON="icon Exports/icon-iOS-Default-1024x1024@1x.png"
DARK_ICON="icon Exports/icon-iOS-Dark-1024x1024@1x.png"
TINTED_ICON="icon Exports/icon-iOS-TintedLight-1024x1024@1x.png" # Using TintedLight as base for tinting

# Verify files exist
if [ ! -f "$LIGHT_ICON" ] || [ ! -f "$DARK_ICON" ]; then
    echo "Error: Source icons not found in 'icon Exports'"
    exit 1
fi

# 2. Copy icons to iconset with standardized names
cp "$LIGHT_ICON" "$ICONSET_DIR/Light.png"
cp "$DARK_ICON" "$ICONSET_DIR/Dark.png"
if [ -f "$TINTED_ICON" ]; then
    cp "$TINTED_ICON" "$ICONSET_DIR/Tinted.png"
else
    # Fallback if specific tinted icon missing
    cp "$LIGHT_ICON" "$ICONSET_DIR/Tinted.png"
fi

# 3. Create Contents.json for AppIcon
# This tells macOS which icon is for which mode
cat > "$ICONSET_DIR/Contents.json" <<EOF
{
  "images" : [
    {
      "filename" : "Light.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "1024x1024"
    },
    {
      "filename" : "Light.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "Dark.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "Dark.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# 4. Compile Assets.car using actool
echo "Compiling Assets.car..."
xcrun actool "$ASSETS_DIR" \
    --compile Resources \
    --platform macosx \
    --minimum-deployment-target 13.0 \
    --app-icon AppIcon \
    --output-partial-info-plist Resources/Assets.plist

# Cleanup
rm -rf "$ASSETS_DIR"

if [ -f "Resources/Assets.car" ]; then
    echo "✅ Successfully created Resources/Assets.car"
else
    echo "❌ Failed to create Assets.car"
    exit 1
fi

