// OpenRunCat/Models/SpeedSource.swift

import Foundation

enum SpeedSource: String, Codable, CaseIterable {
    case cpu = "CPU Usage"
    case memory = "Memory Usage"
    case diskIO = "Disk I/O"
    case networkIO = "Network I/O"

    var displayName: String {
        return NSLocalizedString(rawValue, comment: "Speed source option")
    }
}