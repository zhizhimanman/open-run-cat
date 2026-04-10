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

    func speedValue(for source: SpeedSource) -> Double {
        switch source {
        case .cpu: return cpuUsage
        case .memory: return memoryUsage
        case .gpu: return gpuUsage ?? cpuUsage
        }
    }
}