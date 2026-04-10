// OpenRunCat/Models/AppTheme.swift

import Foundation

enum AppTheme: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var displayName: String {
        return NSLocalizedString(rawValue, comment: "Theme option")
    }
}