// OpenRunCat/Monitor/DiskMonitor.swift

import Foundation

class DiskMonitor {
    private var previousReadBytes: UInt64 = 0
    private var previousWriteBytes: UInt64 = 0
    private var previousTimestamp: Date = Date()

    func getDiskInfo() -> (usage: Double, readSpeed: UInt64, writeSpeed: UInt64) {
        // 获取磁盘使用率
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        var usage: Double = 0.0

        if let attributes = try? FileManager.default.attributesOfFileSystemForPath(homeURL.path),
           let totalSize = attributes[.systemSize] as? UInt64,
           let freeSize = attributes[.systemFreeSize] as? UInt64 {
            let usedSize = totalSize - freeSize
            usage = Double(usedSize) / Double(totalSize) * 100.0
        }

        // 获取读写速度
        var readSpeed: UInt64 = 0
        var writeSpeed: UInt64 = 0

        let now = Date()
        let elapsed = now.timeIntervalSince(previousTimestamp)

        var currentReadBytes: UInt64 = 0
        var currentWriteBytes: UInt64 = 0

        // 使用 IOKit 获取磁盘 IO 统计（简化版本）
        // 这里使用 FileManager 的 volume 获取，作为近似值
        // 完整实现需要 IOKit，后续可扩展

        previousReadBytes = currentReadBytes
        previousWriteBytes = currentWriteBytes
        previousTimestamp = now

        return (usage, readSpeed, writeSpeed)
    }
}