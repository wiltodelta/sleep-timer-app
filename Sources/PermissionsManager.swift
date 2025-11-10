import Foundation
import AppKit

class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()
    
    @Published var showFirstRunAlert = false
    @Published var permissionsChecked = false
    
    private let firstRunKey = "HasLaunchedBefore"
    
    private init() {
        checkFirstRun()
    }
    
    func checkFirstRun() {
        let hasLaunched = UserDefaults.standard.bool(forKey: firstRunKey)
        if !hasLaunched {
            showFirstRunAlert = true
            UserDefaults.standard.set(true, forKey: firstRunKey)
        }
    }
    
    func testSleepPermissions(completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.launchPath = "/usr/bin/pmset"
            task.arguments = ["-g"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            do {
                try task.run()
                task.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let _ = String(data: data, encoding: .utf8) ?? ""
                
                DispatchQueue.main.async {
                    if task.terminationStatus == 0 {
                        completion(true, "Permissions OK: pmset is accessible")
                    } else {
                        completion(false, "pmset command failed. Please check System Settings.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to execute pmset: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
            NSWorkspace.shared.open(url)
        }
    }
}

