// OpenRunCat/Utilities/ByteFormatter.swift

import Foundation

class ByteFormatter {
    static func formatBytes(_ bytes: UInt64) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", Double(bytes) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB", Double(bytes) / (1024.0 * 1024.0 * 1024.0))
        }
    }

    static func formatSpeed(_ bytesPerSecond: UInt64) -> String {
        if bytesPerSecond < 1024 {
            return "\(bytesPerSecond) B/s"
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", Double(bytesPerSecond) / 1024.0)
        } else if bytesPerSecond < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", Double(bytesPerSecond) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB/s", Double(bytesPerSecond) / (1024.0 * 1024.0 * 1024.0))
        }
    }

    static func gbFromBytes(_ bytes: UInt64) -> Double {
        return Double(bytes) / (1024.0 * 1024.0 * 1024.0)
    }
}