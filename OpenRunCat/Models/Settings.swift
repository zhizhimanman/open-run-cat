// OpenRunCat/Models/Settings.swift

import Foundation

struct Settings: Codable {
    var selectedRunner: String = "builtin-Cat"
    var speedSource: SpeedSource = .cpu
    var theme: AppTheme = .system
    var fpsLimit: FPSLimit = .none
    var launchAtLogin: Bool = false

    static var `default`: Settings {
        return Settings()
    }
}