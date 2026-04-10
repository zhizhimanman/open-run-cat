// OpenRunCatTests/MonitorTests/SystemMonitorTests.swift

import XCTest
@testable import OpenRunCat

class SystemMonitorTests: XCTestCase {
    var monitor: SystemMonitor!

    override func setUp() {
        monitor = SystemMonitor()
    }

    override func tearDown() {
        monitor.stopMonitoring()
    }

    func testCPUMonitorReturnsValidRange() {
        monitor.startMonitoring()
        // 等待第一次更新
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertGreaterThanOrEqual(monitor.metrics.cpuUsage, 0.0)
        XCTAssertLessThanOrEqual(monitor.metrics.cpuUsage, 100.0)
    }

    func testMemoryMonitorReturnsValidRange() {
        monitor.startMonitoring()
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertGreaterThanOrEqual(monitor.metrics.memoryUsage, 0.0)
        XCTAssertLessThanOrEqual(monitor.metrics.memoryUsage, 100.0)
        XCTAssertGreaterThan(monitor.metrics.memoryTotal, 0)
    }

    func testSpeedSourceCPU() {
        monitor.metrics.cpuUsage = 50.0
        let speed = monitor.getSpeedForSource(.cpu)
        XCTAssertEqual(speed, 50.0)
    }

    func testSpeedSourceMemory() {
        monitor.metrics.memoryUsage = 75.0
        let speed = monitor.getSpeedForSource(.memory)
        XCTAssertEqual(speed, 75.0)
    }

    func testSpeedSourceDiskIO() {
        monitor.metrics.diskUsage = 40.0
        let speed = monitor.getSpeedForSource(.diskIO)
        XCTAssertEqual(speed, 40.0)
    }

    func testDiskMonitorReturnsValidRange() {
        monitor.startMonitoring()
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertGreaterThanOrEqual(monitor.metrics.diskUsage, 0.0)
        XCTAssertLessThanOrEqual(monitor.metrics.diskUsage, 100.0)
    }
}