# Sleep Timer for macOS

[![Build Sleep Timer App](https://github.com/wiltodelta/sleep-timer-app/actions/workflows/build.yml/badge.svg)](https://github.com/wiltodelta/sleep-timer-app/actions/workflows/build.yml)

A menu bar application for macOS that allows you to set a sleep timer to automatically put your Mac to sleep. Features both manual timer mode and intelligent camera-based sleep detection.

## Screenshots

<p align="center">
  <img src="screenshots/manual-timer.png" alt="Sleep Timer - Manual Mode" width="280">
  <img src="screenshots/active-manual-timer.png" alt="Sleep Timer - Active Timer" width="280">
  <img src="screenshots/camera-mode.png" alt="Sleep Timer - Camera Mode" width="280">
</p>

## Features

### Manual Timer Mode
- 🌙 Menu bar integration - always accessible from your Mac's menu bar
- ⏰ Flexible timer - set from 15 minutes to 12 hours
- 🎯 Quick presets - 15 min, 30 min, 1h, 1.5h, 2h, 3h, 4h, 6h
- ➕ Extend timer - add 5, 15, 30, or 60 minutes to active timer
- 📊 Visual progress - circular progress indicator with remaining time
- 🌙 Active timer indicator - menu bar icon changes when timer is running

### Camera-Based Sleep Detection (NEW in v1.1.0)
- 📷 Automatic sleep detection - monitors your eyes using the camera
- 👁️ Eye tracking - uses Vision Framework with Eye Aspect Ratio (EAR) algorithm
- 🛌 Smart timer - automatically starts 30-minute timer when eyes are closed
- 👀 Wake detection - cancels timer when you open your eyes
- 🔒 Privacy-focused - all processing happens on-device

### General Features
- 🚀 Launch at Login - option to start automatically at login
- 🎨 Liquid Glass design - modern macOS UI with translucent materials
- 💫 Dynamic menu bar icon - moon/filled moon/eye states
- 🔋 Energy efficient - optimized for minimal battery impact

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel Mac (runs via Rosetta 2)
- Xcode 15.0 or later (for building from source)

## Installation

### Option 1: Download Pre-built App (Recommended)

1. Go to [Actions](https://github.com/wiltodelta/sleep-timer-app/actions) tab
2. Click on the latest successful build
3. Download `Sleep-Timer-macOS` artifact
4. Unzip the downloaded file
5. **Important**: Remove the quarantine attribute:
   ```bash
   xattr -cr "Sleep Timer.app"
   ```
6. Move `Sleep Timer.app` to Applications folder

> **Note**: The app is not notarized by Apple, so you need to remove the quarantine attribute or right-click and select "Open" the first time.
>
> **Security**: If you have concerns about running a pre-built app, you can always review the source code and build it yourself (see Option 2 below).

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

### Manual Timer Mode
1. Launch the application - a moon icon will appear in your menu bar
2. Click the moon icon to open the timer interface
3. Select "Timer" mode at the top
4. Set your desired sleep time:
   - Use the slider for custom times
   - Click a preset button for quick selection
5. Click "Start Timer" to begin
6. The menu bar icon changes to indicate an active timer (filled moon)
7. Click the menu bar icon again to:
   - View remaining time and progress
   - Add more time if needed
   - Cancel the timer

### Camera Mode
1. Click the moon icon in your menu bar
2. Select "Camera" mode at the top
3. Grant camera permission when prompted
4. The app will start tracking your eyes
5. When your eyes are closed for ~15 seconds, a 30-minute timer starts automatically
6. Open your eyes for a few seconds to cancel the timer
7. The menu bar shows an eye icon (👁️) when camera mode is active

## Permissions

The app requires the following permissions:

**Required:**
- System Events permission - to put your Mac to sleep

**Optional (for Camera Mode):**
- Camera access - to detect when your eyes are closed
- All camera processing happens on-device; no data is sent anywhere

## Technical Details

- Built with Swift and SwiftUI
- Uses `pmset sleepnow` command to sleep the Mac
- Runs as menu bar only application (no dock icon)
- Launch at Login support via `SMAppService`
- Camera mode uses Vision Framework for face and eye detection
- Eye Aspect Ratio (EAR) algorithm for sleep detection
- Optimized performance with cached frame counting (O(1) complexity)
- Minimal resource usage and energy efficient

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

## Development

### Running Tests

The project includes comprehensive unit tests for core functionality:

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

Test coverage includes:
- **TimerManager**: Timer lifecycle, add time, notifications
- **SleepDetectionManager**: Camera mode, state management, initialization

### Building from Source

```bash
# Quick run for development
./run.sh

# Build release version
swift build -c release

# Create app bundle
./create-app.sh
```

## License

MIT License - feel free to use this project for personal or commercial purposes.

## Troubleshooting

**"Sleep Timer is damaged and can't be opened" error:**
- This is macOS Gatekeeper blocking unsigned apps downloaded from the internet
- To fix this, first navigate to Applications folder in Terminal:
  ```bash
  cd /Applications
  ```
- Then run this command to remove the quarantine attribute:
  ```bash
  xattr -cr "Sleep Timer.app"
  ```
- Alternatively, right-click the app in Finder, select "Open", and confirm in the dialog
- **Why this happens**: The app is not notarized by Apple, so macOS marks it as potentially unsafe

**Timer doesn't put Mac to sleep:**
- Check System Settings > Privacy & Security > Automation
- Ensure the app has permission to control System Events

**Camera mode not working:**
- Check System Settings > Privacy & Security > Camera
- Ensure Sleep Timer has camera access enabled
- Make sure your face is visible and well-lit
- The camera green indicator should be visible when camera mode is active

**"Looking for your face..." message:**
- Ensure your face is centered and clearly visible to the camera
- Check lighting conditions - avoid backlighting
- Clean your camera lens if needed
- Make sure no other app is using the camera

**App doesn't appear in menu bar:**
- Check that you're running macOS 13.0 or later
- Try quitting and restarting the application

## Credits

Created with ❤️ for Mac users who want better control over their sleep schedules.
