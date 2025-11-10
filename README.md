# Sleep Timer for macOS

[![Build Sleep Timer App](https://github.com/wiltodelta/sleep-timer-app/actions/workflows/build.yml/badge.svg)](https://github.com/wiltodelta/sleep-timer-app/actions/workflows/build.yml)

A menu bar application for macOS that allows you to set a sleep timer to automatically put your Mac to sleep after a specified time.

## Features

- 🌙 Menu bar integration - always accessible from your Mac's menu bar
- ⏰ Flexible timer - set from 15 minutes to 12 hours
- 🎯 Quick presets - 30 min, 1h, 1.5h, 2h, 3h, 4h, 6h, 8h
- ➕ Extend timer - add 5, 15, 30, or 60 minutes to active timer
- 📊 Visual progress - circular progress indicator with remaining time
- 🔔 Menu bar countdown - see remaining time in menu bar
- 🎨 Modern SwiftUI interface

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)

## Installation

### Option 1: Download Pre-built App (Recommended)

1. Go to [Actions](https://github.com/wiltodelta/sleep-timer-app/actions) tab
2. Click on the latest successful build
3. Download `Sleep-Timer-macOS` artifact
4. Unzip and move `Sleep Timer.app` to Applications folder

> **Note**: You may need to right-click the app and select "Open" the first time due to macOS Gatekeeper.

### Option 2: Building from Source

1. Clone the repository:
```bash
git clone https://github.com/wiltodelta/sleep-timer-app.git
cd sleep-timer-app
```

2. Create app bundle:
```bash
./create-app.sh
```

3. Open the app:
```bash
open "Sleep Timer.app"
```

Or move to Applications:
```bash
mv "Sleep Timer.app" /Applications/
```

## Usage

1. Launch the application - a moon icon will appear in your menu bar
2. Click the moon icon to open the timer interface
3. Set your desired sleep time:
   - Use the slider for custom times
   - Click a preset button for quick selection
4. Click "Start Timer" to begin
5. The menu bar will show the countdown
6. Click the menu bar icon again to:
   - View remaining time and progress
   - Add more time if needed
   - Cancel the timer

## Permissions

The app requires permission to put your Mac to sleep. On first use, macOS may prompt you to grant necessary permissions:
- System Events permission (for sleep command)

## Technical Details

- Built with Swift and SwiftUI
- Uses `pmset sleepnow` command to sleep the Mac
- Fallback to AppleScript if pmset fails
- Runs as menu bar only application (no dock icon)
- Minimal resource usage

## Releases

To create a new release with automatic app building:

1. Tag your commit:
```bash
git tag v1.0.0
git push origin v1.0.0
```

2. GitHub Actions will automatically:
   - Build the app
   - Create a release
   - Attach the app as a downloadable asset

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this project for personal or commercial purposes.

## Troubleshooting

**Timer doesn't put Mac to sleep:**
- Check System Settings > Privacy & Security > Automation
- Ensure the app has permission to control System Events

**App doesn't appear in menu bar:**
- Check that you're running macOS 13.0 or later
- Try quitting and restarting the application

## Credits

Created with ❤️ for Mac users who want better control over their sleep schedules.
