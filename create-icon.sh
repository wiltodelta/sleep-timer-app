#!/bin/bash

# Create temporary directory for icon generation
TEMP_DIR=$(mktemp -d)
ICON_DIR="$TEMP_DIR/AppIcon.iconset"
mkdir -p "$ICON_DIR"

# Generate icon from SF Symbol using Swift
cat > "$TEMP_DIR/generate_icon.swift" << 'EOF'
import Cocoa
import AppKit

func createIcon(size: CGFloat, filename: String) {
    let config = NSImage.SymbolConfiguration(pointSize: size * 0.6, weight: .regular)
    guard let symbol = NSImage(systemSymbolName: "moon.zzz.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else {
        print("Failed to create symbol")
        return
    }
    
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    // Background gradient (lighter)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.4, green: 0.5, blue: 0.75, alpha: 1.0),
        NSColor(red: 0.3, green: 0.4, blue: 0.65, alpha: 1.0)
    ])
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    gradient?.draw(in: rect, angle: -45)
    
    // Draw symbol in center
    let symbolRect = NSRect(
        x: (size - size * 0.6) / 2,
        y: (size - size * 0.6) / 2,
        width: size * 0.6,
        height: size * 0.6
    )
    NSColor.white.withAlphaComponent(0.95).set()
    symbol.draw(in: symbolRect)
    
    image.unlockFocus()
    
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG")
        return
    }
    
    let url = URL(fileURLWithPath: filename)
    try? pngData.write(to: url)
}

// Generate all required icon sizes
let sizes: [(size: CGFloat, name: String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

let iconsetPath = CommandLine.arguments[1]
for (size, name) in sizes {
    createIcon(size: size, filename: "\(iconsetPath)/\(name)")
}
EOF

# Compile and run the Swift script
echo "Generating icon images..."
swiftc "$TEMP_DIR/generate_icon.swift" -o "$TEMP_DIR/generate_icon"
"$TEMP_DIR/generate_icon" "$ICON_DIR"

# Convert to .icns
echo "Creating .icns file..."
mkdir -p Resources
iconutil -c icns "$ICON_DIR" -o "Resources/AppIcon.icns"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Icon created: Resources/AppIcon.icns"
