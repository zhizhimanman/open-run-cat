// OpenRunCat/Monitor/MemoryMonitor.swift

import Foundation

class MemoryMonitor {
    func getMemoryInfo() -> (usage: Double, used: UInt64, total: UInt64) {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self_, HOST_VM_INFO64, $0, &count)
            }
        }

        if result != KERN_SUCCESS {
            return (0.0, 0, 0)
        }

        let pageSize = UInt64(vm_kernel_page_size)
        let free = UInt64(vmStats.free_count) * pageSize
        let active = UInt64(vmStats.active_count) * pageSize
        let inactive = UInt64(vmStats.inactive_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize

        let used = active + wired
        let total = used + free + inactive

        let usage = total > 0 ? Double(used) / Double(total) * 100.0 : 0.0

        return (usage, used, total)
    }
}