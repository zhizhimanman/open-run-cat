// OpenRunCat/Settings/LaunchAtLoginManager.swift

import Foundation
import ServiceManagement

class LaunchAtLoginManager {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to set launch at login: \(error)")
        }
    }

    static func isEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
}