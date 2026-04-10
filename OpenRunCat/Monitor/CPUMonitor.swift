// OpenRunCat/Monitor/CPUMonitor.swift

import Foundation

class CPUMonitor {
    private var previousTotal: UInt64 = 0
    private var previousIdle: UInt64 = 0

    func getUsage() -> Double {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0

        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        if result != KERN_SUCCESS {
            return 0.0
        }

        var totalUsage: Double = 0.0
        if let threads = threadList {
            for i in 0..<Int(threadCount) {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)

                let kr = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                        thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }

                if kr == KERN_SUCCESS && threadInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsage += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride))
        }

        return min(totalUsage, 100.0)
    }
}