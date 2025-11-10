# Sleep Timer for macOS

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

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/sleep-timer-app.git
cd sleep-timer-app
```

2. Build the application using Swift Package Manager:
```bash
swift build -c release
```

3. Run the application:
```bash
.build/release/SleepTimer
```

### Creating a Standalone App

To create a standalone `.app` bundle that can be moved to Applications folder:

1. Open the project in Xcode:
```bash
open Package.swift
```

2. In Xcode:
   - Select Product > Archive
   - Export the application
   - Move to Applications folder

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

## Development

### Project Structure

```
sleep-timer-app/
├── Package.swift           # Swift Package Manager configuration
├── Sources/
│   ├── SleepTimerApp.swift    # Main app entry point and menu bar setup
│   ├── TimerManager.swift     # Timer logic and sleep command
│   └── ContentView.swift      # SwiftUI user interface
└── README.md
```

### Key Components

- **SleepTimerApp**: Main app structure with AppDelegate for menu bar
- **TimerManager**: Singleton managing timer state and sleep functionality
- **ContentView**: SwiftUI views for timer interface
- **InactiveTimerView**: Timer setup interface
- **ActiveTimerView**: Active timer with progress and controls

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

## Future Enhancements

- [ ] Custom alert sound before sleep
- [ ] Keyboard shortcuts
- [ ] Launch at login option
- [ ] Sleep schedule presets
- [ ] Dark mode support
- [ ] Notifications before sleep
- [ ] Statistics tracking

## Credits

Created with ❤️ for Mac users who want better control over their sleep schedules.

