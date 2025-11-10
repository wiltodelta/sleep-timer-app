import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager.shared
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var selectedHours: Double = 1.0
    @State private var showPermissionsHelp = false
    
    var body: some View {
        VStack(spacing: 0) {
            if timerManager.isTimerActive {
                ActiveTimerView()
            } else {
                InactiveTimerView(
                    selectedHours: $selectedHours,
                    showPermissionsHelp: $showPermissionsHelp
                )
            }
        }
        .frame(width: 280)
        .alert("Welcome to Sleep Timer", isPresented: $permissionsManager.showFirstRunAlert) {
            Button("Open Settings") {
                PermissionsManager.shared.openSystemSettings()
            }
            Button("Got It") {
                permissionsManager.showFirstRunAlert = false
            }
        } message: {
            Text("To automatically sleep your Mac, this app uses the 'pmset' command.\n\nIf sleep doesn't work, you may need to grant permissions in System Settings > Privacy & Security > Automation.\n\nYou can test permissions anytime from the Help menu.")
        }
        .sheet(isPresented: $showPermissionsHelp) {
            PermissionsHelpView(isPresented: $showPermissionsHelp)
        }
    }
}

struct InactiveTimerView: View {
    @Binding var selectedHours: Double
    @Binding var showPermissionsHelp: Bool
    @StateObject private var launchManager = LaunchAtLoginManager.shared
    
    private let presetHours: [Double] = [0.5, 1, 1.5, 2, 3, 4, 6, 8]
    
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
                
                HStack(spacing: 12) {
                    Button("Help") {
                        showPermissionsHelp = true
                    }
                    .buttonStyle(.plain)
                    .controlSize(.small)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .controlSize(.small)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                }
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

struct PermissionsHelpView: View {
    @Binding var isPresented: Bool
    @State private var testResult: String = ""
    @State private var testSuccess: Bool = false
    @State private var isTesting: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Permissions & Help")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How It Works")
                        .font(.headline)
                    Text("Sleep Timer uses the macOS 'pmset' command to put your Mac to sleep. This is a system utility that may require permissions.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("If Sleep Doesn't Work:")
                        .font(.headline)
                    Text("1. Open System Settings\n2. Go to Privacy & Security > Automation\n3. Enable permissions for Sleep Timer\n4. Test again using the button below")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    HStack {
                        Button(isTesting ? "Testing..." : "Test Permissions") {
                            testPermissions()
                        }
                        .disabled(isTesting)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Open System Settings") {
                            PermissionsManager.shared.openSystemSettings()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    
                    if !testResult.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: testSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(testSuccess ? .green : .red)
                            Text(testResult)
                                .font(.system(size: 12))
                                .foregroundColor(testSuccess ? .green : .red)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(testSuccess ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            Button("Close") {
                isPresented = false
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding(24)
        .frame(width: 480, height: 480)
    }
    
    private func testPermissions() {
        isTesting = true
        testResult = ""
        
        PermissionsManager.shared.testSleepPermissions { success, message in
            testSuccess = success
            testResult = message
            isTesting = false
        }
    }
}

