// OpenRunCat/Monitor/CPUMonitor.swift

import Foundation

class CPUMonitor {
    private var previousTotal: UInt64 = 0
    private var previousIdle: UInt64 = 0
    private var previousUser: UInt64 = 0
    private var previousSystem: UInt64 = 0
    private var previousNice: UInt64 = 0

    func getUsage() -> Double {
        var cpuLoadInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        if result != KERN_SUCCESS {
            return 0.0
        }

        let user = UInt64(cpuLoadInfo.cpu_ticks.0)
        let system = UInt64(cpuLoadInfo.cpu_ticks.1)
        let idle = UInt64(cpuLoadInfo.cpu_ticks.2)
        let nice = UInt64(cpuLoadInfo.cpu_ticks.3)

        let total = user + system + idle + nice

        if previousTotal == 0 {
            previousTotal = total
            previousUser = user
            previousSystem = system
            previousIdle = idle
            previousNice = nice
            return 0.0
        }

        let deltaTotal = total - previousTotal
        let deltaIdle = idle - previousIdle

        previousTotal = total
        previousUser = user
        previousSystem = system
        previousIdle = idle
        previousNice = nice

        if deltaTotal == 0 {
            return 0.0
        }

        let usage = Double(deltaTotal - deltaIdle) / Double(deltaTotal) * 100.0
        return min(max(usage, 0.0), 100.0)
    }
}