// OpenRunCat/Models/SpeedSource.swift

enum SpeedSource: String, Codable, CaseIterable {
    case cpu = "CPU"
    case memory = "Memory"
    case gpu = "GPU"

    var displayName: String {
        return rawValue
    }
}