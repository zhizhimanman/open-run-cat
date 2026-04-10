// OpenRunCat/Monitor/GPUMonitor.swift

import Foundation

class GPUMonitor {
    func getUsage() -> Double? {
        // macOS GPU 监控需要使用 IOKit 或 Metal
        // 部分 Mac（如老款 Intel）可能不支持
        // 简化版本返回 nil
        return nil
    }
}