// OpenRunCat/Models/FPSLimit.swift

enum FPSLimit: String, Codable, CaseIterable {
    case none = "None"
    case fps30 = "30"
    case fps60 = "60"

    var displayName: String {
        return rawValue
    }

    var value: Double? {
        switch self {
        case .none: return nil
        case .fps30: return 30.0
        case .fps60: return 60.0
        }
    }
}