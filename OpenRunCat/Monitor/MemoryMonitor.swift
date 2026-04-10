// OpenRunCat/Monitor/MemoryMonitor.swift

import Foundation

class MemoryMonitor {
    func getMemoryInfo() -> (usage: Double, used: UInt64, total: UInt64) {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result != KERN_SUCCESS {
            return (0.0, 0, 0)
        }

        let pageSize = UInt64(vm_kernel_page_size)

        // 计算 Apple 风格的内存使用
        // 已用内存 = 活跃 + 被钉住 + 压缩
        let active = UInt64(vmStats.active_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize
        let compressed = UInt64(vmStats.compressor_page_count) * pageSize
        let used = active + wired + compressed

        // 总内存从系统获取
        let total = ProcessInfo.processInfo.physicalMemory

        // 计算使用率
        let usage = total > 0 ? Double(used) / Double(total) * 100.0 : 0.0

        return (usage, used, total)
    }
}