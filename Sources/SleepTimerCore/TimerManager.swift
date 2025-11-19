import Foundation
import AppKit

public class TimerManager: ObservableObject {
    public static let shared = TimerManager()

    @Published public var isTimerActive: Bool = false
    @Published public var remainingTime: TimeInterval = 0
    @Published public var totalTime: TimeInterval = 0

    private var timer: Timer?
    private var targetDate: Date?

    private init() {}

    public func startTimer(hours: Double) {
        stopTimer()

        totalTime = hours * 3600
        remainingTime = totalTime
        targetDate = Date().addingTimeInterval(totalTime)
        isTimerActive = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }

        notifyTimerUpdated()
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        remainingTime = 0
        totalTime = 0
        targetDate = nil
        notifyTimerUpdated()
    }

    private func updateTimer() {
        guard let targetDate = targetDate else {
            stopTimer()
            return
        }

        remainingTime = targetDate.timeIntervalSinceNow

        if remainingTime <= 0 {
            // Notify that timer finished (so we can disable camera mode)
            NotificationCenter.default.post(name: NSNotification.Name("TimerDidFinish"), object: nil)

            stopTimer()
            putComputerToSleep()
        }

        notifyTimerUpdated()
    }

    private func putComputerToSleep() {
        NSLog("DEBUG: putComputerToSleep() called")

        // Disable camera mode before sleep (switch back to manual mode)
        SleepDetectionManager.shared.setCameraModeEnabled(false)

        // Notify UI to switch back to manual mode
        NotificationCenter.default.post(name: NSNotification.Name("CameraModeDisabled"), object: nil)

        // Use pmset command (most reliable method)
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["sleepnow"]

        do {
            try task.run()
            NSLog("DEBUG: pmset sleepnow executed successfully")
        } catch {
            NSLog("Failed to put computer to sleep: \(error)")

            // Show alert to user
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)

                let alert = NSAlert()
                alert.messageText = "Sleep Failed"
                alert.informativeText = "Unable to put the computer to sleep.\n\nError: \(error.localizedDescription)"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()

                NSApp.setActivationPolicy(.accessory)
            }
        }
    }

    private func notifyTimerUpdated() {
        NotificationCenter.default.post(name: NSNotification.Name("TimerUpdated"), object: nil)
    }

    public func addTime(minutes: Int) {
        guard isTimerActive, let currentTarget = targetDate else { return }

        let newTarget = currentTarget.addingTimeInterval(TimeInterval(minutes * 60))
        targetDate = newTarget
        totalTime += TimeInterval(minutes * 60)
        updateTimer()
    }

    public func sleepNow() {
        NSLog("DEBUG: sleepNow() called from external trigger")
        putComputerToSleep()
    }
}
