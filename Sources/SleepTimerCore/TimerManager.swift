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
            stopTimer()
            putComputerToSleep()
        }

        notifyTimerUpdated()
    }

    private func putComputerToSleep() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["sleepnow"]

        do {
            try task.run()
        } catch {
            print("Failed to put computer to sleep: \(error)")
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
}
