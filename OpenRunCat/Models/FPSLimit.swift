// OpenRunCat/Models/FPSLimit.swift

import Foundation

enum FPSLimit: String, Codable, CaseIterable {
    case none = "None"
    case fps5 = "5 FPS"
    case fps10 = "10 FPS"
    case fps15 = "15 FPS"
    case fps30 = "30 FPS"
    case fps60 = "60 FPS"

    var displayName: String {
        return NSLocalizedString(rawValue, comment: "FPS limit option")
    }

    var value: Double? {
        switch self {
        case .none: return nil
        case .fps5: return 5.0
        case .fps10: return 10.0
        case .fps15: return 15.0
        case .fps30: return 30.0
        case .fps60: return 60.0
        }
    }
}