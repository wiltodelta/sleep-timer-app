import SwiftUI

@main
struct SleepTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var timerManager = TimerManager.shared
    private var sleepManager = SleepDetectionManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Check launch at login status
        LaunchAtLoginManager.shared.checkStatus()

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "moon", accessibilityDescription: "Sleep Timer")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 360)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // Update icon when timer changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TimerUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatusItem()
        }

        // Update icon when camera mode changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CameraModeChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatusItem()
        }

        updateStatusItem()
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                // Always reposition popover relative to current button bounds
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    private func updateStatusItem() {
        if let button = statusItem.button {
            let iconName: String
            
            if timerManager.isTimerActive {
                // Timer is active (any mode) - always moon.fill
                iconName = "moon.fill"
            } else if sleepManager.isCameraModeEnabled {
                // Camera mode with no active timer - eye icon
                iconName = "eye.fill"
            } else {
                // Manual mode with no active timer - regular moon
                iconName = "moon"
            }
            
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Sleep Timer")
        }
    }
}
