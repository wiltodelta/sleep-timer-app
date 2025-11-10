import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager.shared
    @State private var selectedHours: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {
            if timerManager.isTimerActive {
                ActiveTimerView()
            } else {
                InactiveTimerView(selectedHours: $selectedHours)
            }
        }
        .frame(width: 280)
    }
}

struct InactiveTimerView: View {
    @Binding var selectedHours: Double
    @StateObject private var launchManager = LaunchAtLoginManager.shared

    private let presetHours: [Double] = [0.25, 0.5, 1, 1.5, 2, 3, 4, 6]

    var body: some View {
        VStack(spacing: 0) {
            // Time display
            VStack(spacing: 12) {
                Text(formatHours(selectedHours))
                    .font(.system(size: 48, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)

                Slider(value: $selectedHours, in: 0.25...12, step: 0.25)
                    .controlSize(.small)

                HStack {
                    Text("15 min")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("12 hours")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .padding(.top, 12)

            Divider()

            // Presets
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(Array(presetHours.prefix(4)), id: \.self) { hours in
                        PresetButton(hours: hours, selectedHours: $selectedHours)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(Array(presetHours.suffix(4)), id: \.self) { hours in
                        PresetButton(hours: hours, selectedHours: $selectedHours)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            // Action buttons
            VStack(spacing: 8) {
                Button("Start Timer") {
                    TimerManager.shared.startTimer(hours: selectedHours)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)

                Divider()
                    .padding(.vertical, 4)

                Toggle(isOn: $launchManager.isEnabled) {
                    Text("Launch at Login")
                        .font(.system(size: 12))
                }
                .toggleStyle(.checkbox)
                .controlSize(.small)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .controlSize(.small)
                .foregroundColor(.secondary)
                .font(.system(size: 11))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private func formatHours(_ hours: Double) -> String {
        if hours < 1 {
            let minutes = Int(hours * 60)
            return "\(minutes) min"
        } else if hours == floor(hours) {
            let h = Int(hours)
            return h == 1 ? "1 hour" : "\(h) hours"
        } else {
            let h = Int(hours)
            let m = Int((hours - Double(h)) * 60)
            if m == 0 {
                return h == 1 ? "1 hour" : "\(h) hours"
            }
            return "\(h)h \(m)m"
        }
    }

    private func formatHoursShort(_ hours: Double) -> String {
        if hours < 1 {
            return "\(Int(hours * 60))m"
        } else if hours == floor(hours) {
            return "\(Int(hours))h"
        } else {
            let h = Int(hours)
            let m = Int((hours - Double(h)) * 60)
            return "\(h)h \(m)m"
        }
    }
}

struct PresetButton: View {
    let hours: Double
    @Binding var selectedHours: Double

    var body: some View {
        Button(action: {
            selectedHours = hours
        }) {
            Text(formatHoursShort(hours))
                .font(.system(size: 11))
                .frame(maxWidth: .infinity)
                .frame(height: 24)
        }
        .buttonStyle(.bordered)
        .tint(selectedHours == hours ? .accentColor : .gray)
        .controlSize(.small)
    }

    private func formatHoursShort(_ hours: Double) -> String {
        if hours < 1 {
            return "\(Int(hours * 60))m"
        } else if hours == floor(hours) {
            return "\(Int(hours))h"
        } else {
            let h = Int(hours)
            let m = Int((hours - Double(h)) * 60)
            return "\(h)h \(m)m"
        }
    }
}

struct ActiveTimerView: View {
    @StateObject private var timerManager = TimerManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Circular progress
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color(NSColor.separatorColor), lineWidth: 10)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: CGFloat(timerManager.remainingTime / timerManager.totalTime))
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text(formatTime(timerManager.remainingTime))
                            .font(.system(size: 26, weight: .medium, design: .rounded))
                            .monospacedDigit()
                        Text("remaining")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: 2) {
                    Text("Sleep at \(formatTargetTime(timerManager.remainingTime))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .padding(.top, 12)

            Divider()

            // Add time buttons
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach([5, 15, 30, 60], id: \.self) { minutes in
                        Button("+\(minutes)m") {
                            timerManager.addTime(minutes: minutes)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            // Cancel button
            Button("Stop Timer") {
                timerManager.stopTimer()
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .controlSize(.large)
            .keyboardShortcut(.cancelAction)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func formatTargetTime(_ remainingTime: TimeInterval) -> String {
        let targetDate = Date().addingTimeInterval(remainingTime)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: targetDate)
    }
}
