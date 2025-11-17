import Foundation
import ServiceManagement

public class LaunchAtLoginManager: ObservableObject {
    public static let shared = LaunchAtLoginManager()

    @Published public var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "LaunchAtLogin")
            if isEnabled {
                enableLaunchAtLogin()
            } else {
                disableLaunchAtLogin()
            }
        }
    }

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "LaunchAtLogin")
    }

    public func checkStatus() {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            isEnabled = service.status == .enabled
        }
    }

    private func enableLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if service.status == .enabled {
                    print("Already enabled")
                } else {
                    try service.register()
                    print("Launch at login enabled")
                }
            } catch {
                print("Failed to enable launch at login: \(error)")
            }
        }
    }

    private func disableLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if service.status == .enabled {
                    try service.unregister()
                    print("Launch at login disabled")
                }
            } catch {
                print("Failed to disable launch at login: \(error)")
            }
        }
    }
}
