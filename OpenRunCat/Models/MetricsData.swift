// OpenRunCat/Models/MetricsData.swift

import Foundation

struct MetricsData {
    var cpuUsage: Double = 0.0
    var memoryUsage: Double = 0.0
    var memoryUsed: UInt64 = 0
    var memoryTotal: UInt64 = 0
    var diskUsage: Double = 0.0
    var diskReadSpeed: UInt64 = 0
    var diskWriteSpeed: UInt64 = 0
    var networkUpSpeed: UInt64 = 0
    var networkDownSpeed: UInt64 = 0
    var gpuUsage: Double? = nil

    var speedValue: Double {
        // 根据当前选定的 SpeedSource 返回对应值
        return cpuUsage // 默认使用 CPU
    }
}