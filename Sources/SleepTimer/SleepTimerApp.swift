import SwiftUI
import SleepTimerCore

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
        popover.contentSize = NSSize(width: 360, height: 420)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.delegate = self

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
                stopMonitoringStatusBarPosition()
                popover.performClose(nil)
            } else {
                // Always reposition popover relative to current button bounds
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()

                // Start monitoring for status item position changes
                startMonitoringStatusBarPosition()
            }
        }
    }

    private var positionMonitorTimer: Timer?

    private func startMonitoringStatusBarPosition() {
        stopMonitoringStatusBarPosition()

        positionMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  self.popover.isShown,
                  let button = self.statusItem.button else {
                self?.stopMonitoringStatusBarPosition()
                return
            }

            // Reposition popover to follow the button
            self.popover.positioningRect = button.bounds
        }
    }

    private func stopMonitoringStatusBarPosition() {
        positionMonitorTimer?.invalidate()
        positionMonitorTimer = nil
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

extension AppDelegate: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        stopMonitoringStatusBarPosition()
    }
}
