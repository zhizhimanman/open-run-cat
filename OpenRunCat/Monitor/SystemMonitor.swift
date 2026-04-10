// OpenRunCat/Monitor/SystemMonitor.swift

import Foundation
import Combine

class SystemMonitor: ObservableObject {
    @Published var metrics: MetricsData = MetricsData()

    private var cpuMonitor = CPUMonitor()
    private var memoryMonitor = MemoryMonitor()
    private var diskMonitor = DiskMonitor()
    private var networkMonitor = NetworkMonitor()
    private var gpuMonitor = GPUMonitor()

    private var timer: Timer?

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: Constants.monitorInterval, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
        updateMetrics() // 立即获取一次
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func updateMetrics() {
        let cpuUsage = cpuMonitor.getUsage()
        let (memoryUsage, memoryUsed, memoryTotal) = memoryMonitor.getMemoryInfo()
        let (diskUsage, diskReadSpeed, diskWriteSpeed) = diskMonitor.getDiskInfo()
        let (networkUpSpeed, networkDownSpeed) = networkMonitor.getNetworkInfo()
        let gpuUsage = gpuMonitor.getUsage()

        metrics = MetricsData(
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            memoryUsed: memoryUsed,
            memoryTotal: memoryTotal,
            diskUsage: diskUsage,
            diskReadSpeed: diskReadSpeed,
            diskWriteSpeed: diskWriteSpeed,
            networkUpSpeed: networkUpSpeed,
            networkDownSpeed: networkDownSpeed,
            gpuUsage: gpuUsage
        )
    }

    func getSpeedForSource(_ source: SpeedSource) -> Double {
        return metrics.speedValue(for: source)
    }
}