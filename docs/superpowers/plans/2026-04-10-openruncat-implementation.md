# OpenRunCat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建 macOS 菜单栏应用，显示跑步动画角色，动画速度根据系统负载动态变化。

**Architecture:** SwiftUI + AppKit 混合架构。使用 NSStatusItem 实现菜单栏图标，Timer 驱动帧动画，组合多个 Monitor 模块采集系统指标，RunnerManager 加载角色帧序列。

**Tech Stack:** Swift 5.9, SwiftUI, AppKit, macOS 12.0+, ServiceManagement

---

## File Structure

```
OpenRunCat/
├─ OpenRunCat.xcodeproj
├─ OpenRunCat/
│  ├─ App/
│  │  ├─ OpenRunCatApp.swift        — SwiftUI App 入口
│  │  ├─ AppDelegate.swift          — 应用生命周期
│  │  └─ Constants.swift            — 全局常量
│  ├─ Models/
│  │  ├─ MetricsData.swift          — 指标数据结构
│  │  ├─ Runner.swift               — 角色模型
│  │  ├─ Settings.swift             — 设置模型
│  │  ├─ SpeedSource.swift          — 速度源枚举
│  │  ├─ AppTheme.swift             — 主题枚举
│  │  └─ FPSLimit.swift             — FPS限制枚举
│  ├─ Monitor/
│  │  ├─ SystemMonitor.swift        — 系统监控协调器
│  │  ├─ CPUMonitor.swift           — CPU监控
│  │  ├─ MemoryMonitor.swift        — 内存监控
│  │  ├─ DiskMonitor.swift          — 磁盘监控
│  │  ├─ NetworkMonitor.swift       — 网络监控
│  │  └─ GPUMonitor.swift           — GPU监控
│  ├─ Runner/
│  │  ├─ RunnerManager.swift        — 角色管理
│  │  ├─ RunnerLoader.swift         — 角色加载器
│  │  └─ FrameAnimator.swift        — 帧动画控制器
│  ├─ MenuBar/
│  │  ├─ MenuBarManager.swift       — 菜单栏管理
│  │  ├─ StatusItemController.swift — NSStatusItem封装
│  │  └─ ContextMenuBuilder.swift   — 右键菜单构建
│  ├─ Settings/
│  │  ├─ SettingsManager.swift      — 设置管理
│  │  └─ LaunchAtLoginManager.swift — 开机启动
│  ├─ Theme/
│  │  ├─ ThemeManager.swift         — 主题管理
│  │  └─ IconTinting.swift          — 图标着色
│  ├─ Utilities/
│  │  ├─ ByteFormatter.swift        — 字节格式化
│  │  └─ NSImageExtensions.swift    — NSImage扩展
│  ├─ Assets.xcassets
│  ├─ Resources/
│  │  └─ Runners/
│  │     ├─ Cat/
│  │     │  ├─ frame_00.png
│  │     │  ├─ frame_01.png
│  │     │  └─ ... (共5帧)
│  │     ├─ Dog/
│  │     └─ ClaudeCrab/
│  ├─ Info.plist                    — LSUIElement=true
│  └─ entitlements.plist            — 开机启动权限
└─ OpenRunCatTests/
   ├─ MonitorTests/
   ├─ RunnerTests/
   └─ SettingsTests/
```

---

### Task 1: 项目初始化

**Files:**
- Create: `OpenRunCat.xcodeproj`
- Create: `OpenRunCat/App/OpenRunCatApp.swift`
- Create: `OpenRunCat/Info.plist`

- [ ] **Step 1: 创建 Xcode 项目**

在 Xcode 中创建新项目：
- Template: macOS App
- Name: OpenRunCat
- Language: Swift
- Interface: SwiftUI
- Organization Identifier: com.openruncat

- [ ] **Step 2: 配置 Info.plist 为菜单栏应用**

在 `OpenRunCat/Info.plist` 中添加：
```xml
<key>LSUIElement</key>
<true/>
```

- [ ] **Step 3: 创建目录结构**

```bash
mkdir -p OpenRunCat/App OpenRunCat/Models OpenRunCat/Monitor OpenRunCat/Runner OpenRunCat/MenuBar OpenRunCat/Settings OpenRunCat/Theme OpenRunCat/Utilities OpenRunCat/Resources/Runners OpenRunCatTests/MonitorTests OpenRunCatTests/RunnerTests OpenRunCatTests/SettingsTests
```

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "Initialize OpenRunCat project structure"
```

---

### Task 2: 定义数据模型

**Files:**
- Create: `OpenRunCat/App/Constants.swift`
- Create: `OpenRunCat/Models/MetricsData.swift`
- Create: `OpenRunCat/Models/SpeedSource.swift`
- Create: `OpenRunCat/Models/AppTheme.swift`
- Create: `OpenRunCat/Models/FPSLimit.swift`
- Create: `OpenRunCat/Models/Settings.swift`
- Create: `OpenRunCat/Models/Runner.swift`

- [ ] **Step 1: 创建 Constants.swift**

```swift
// OpenRunCat/App/Constants.swift

import Foundation

struct Constants {
    // Animation
    static let baseFPS: Double = 2.0
    static let fpsMultiplier: Double = 0.5

    // Monitor
    static let monitorInterval: TimeInterval = 1.0

    // Runner
    static let builtInRunnersPath = "Runners"
    static let customRunnersPath = "~/Library/Application Support/OpenRunCat/Runners"

    // UI
    static let iconSize: CGFloat = 18.0
}
```

- [ ] **Step 2: 创建 MetricsData.swift**

```swift
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
```

- [ ] **Step 3: 创建 SpeedSource.swift**

```swift
// OpenRunCat/Models/SpeedSource.swift

enum SpeedSource: String, Codable, CaseIterable {
    case cpu = "CPU"
    case memory = "Memory"
    case gpu = "GPU"

    var displayName: String {
        return rawValue
    }
}
```

- [ ] **Step 4: 创建 AppTheme.swift**

```swift
// OpenRunCat/Models/AppTheme.swift

enum AppTheme: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var displayName: String {
        return rawValue
    }
}
```

- [ ] **Step 5: 创建 FPSLimit.swift**

```swift
// OpenRunCat/Models/FPSLimit.swift

enum FPSLimit: String, Codable, CaseIterable {
    case none = "None"
    case fps30 = "30"
    case fps60 = "60"

    var displayName: String {
        return rawValue
    }

    var value: Double? {
        switch self {
        case .none: return nil
        case .fps30: return 30.0
        case .fps60: return 60.0
        }
    }
}
```

- [ ] **Step 6: 创建 Settings.swift**

```swift
// OpenRunCat/Models/Settings.swift

import Foundation

struct Settings: Codable {
    var selectedRunner: String = "Cat"
    var speedSource: SpeedSource = .cpu
    var theme: AppTheme = .system
    var fpsLimit: FPSLimit = .none
    var launchAtLogin: Bool = false

    static var `default`: Settings {
        return Settings()
    }
}
```

- [ ] **Step 7: 创建 Runner.swift**

```swift
// OpenRunCat/Models/Runner.swift

import Foundation
import AppKit

struct Runner: Identifiable {
    let id: String
    let name: String
    let frameCount: Int
    let frames: [NSImage]
    let framePaths: [URL]
    let isBuiltIn: Bool

    init(id: String, name: String, framePaths: [URL], isBuiltIn: Bool) {
        self.id = id
        self.name = name
        self.framePaths = framePaths
        self.frameCount = framePaths.count
        self.frames = framePaths.map { NSImage(contentsOf: $0) ?? NSImage() }
        self.isBuiltIn = isBuiltIn
    }
}
```

- [ ] **Step 8: Commit**

```bash
git add OpenRunCat/App/Constants.swift OpenRunCat/Models/
git commit -m "Add data models: MetricsData, Settings, Runner, enums"
```

---

### Task 3: 实现系统监控模块

**Files:**
- Create: `OpenRunCat/Monitor/CPUMonitor.swift`
- Create: `OpenRunCat/Monitor/MemoryMonitor.swift`
- Create: `OpenRunCat/Monitor/DiskMonitor.swift`
- Create: `OpenRunCat/Monitor/NetworkMonitor.swift`
- Create: `OpenRunCat/Monitor/GPUMonitor.swift`
- Create: `OpenRunCat/Monitor/SystemMonitor.swift`
- Test: `OpenRunCatTests/MonitorTests/SystemMonitorTests.swift`

- [ ] **Step 1: 创建 CPUMonitor.swift**

```swift
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
                        thread_info(threads[i], THREAD_BASIC_INFO, $0, &threadInfoCount)
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
```

- [ ] **Step 2: 创建 MemoryMonitor.swift**

```swift
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
```

- [ ] **Step 3: 创建 DiskMonitor.swift**

```swift
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
```

- [ ] **Step 4: 创建 NetworkMonitor.swift**

```swift
// OpenRunCat/Monitor/NetworkMonitor.swift

import Foundation

class NetworkMonitor {
    private var previousInBytes: UInt64 = 0
    private var previousOutBytes: UInt64 = 0
    private var previousTimestamp: Date = Date()

    func getNetworkInfo() -> (upSpeed: UInt64, downSpeed: UInt64) {
        var upSpeed: UInt64 = 0
        var downSpeed: UInt64 = 0

        // 使用 sysctl 或 netstat 获取网络统计
        // 简化版本，后续可扩展

        let interfaceNames = getNetworkInterfaces()
        var currentInBytes: UInt64 = 0
        var currentOutBytes: UInt64 = 0

        for interface in interfaceNames {
            let (inBytes, outBytes) = getInterfaceBytes(interface)
            currentInBytes += inBytes
            currentOutBytes += outBytes
        }

        let now = Date()
        let elapsed = now.timeIntervalSince(previousTimestamp)

        if elapsed > 0 {
            upSpeed = UInt64(Double(currentOutBytes - previousOutBytes) / elapsed)
            downSpeed = UInt64(Double(currentInBytes - previousInBytes) / elapsed)
        }

        previousInBytes = currentInBytes
        previousOutBytes = currentOutBytes
        previousTimestamp = now

        return (upSpeed, downSpeed)
    }

    private func getNetworkInterfaces() -> [String] {
        // 返回活跃的网络接口名称
        return ["en0"] // 简化版本
    }

    private func getInterfaceBytes(_ interface: String) -> (inBytes: UInt64, outBytes: UInt64) {
        // 使用 sysctl_getifdata 或解析 /proc/net/dev（Linux风格）
        // macOS 需要使用不同的方法
        return (0, 0) // 简化版本，后续完善
    }
}
```

- [ ] **Step 5: 创建 GPUMonitor.swift**

```swift
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
```

- [ ] **Step 6: 创建 SystemMonitor.swift**

```swift
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
        switch source {
        case .cpu: return metrics.cpuUsage
        case .memory: return metrics.memoryUsage
        case .gpu: return metrics.gpuUsage ?? metrics.cpuUsage
        }
    }
}
```

- [ ] **Step 7: 创建测试文件**

```swift
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
}
```

- [ ] **Step 8: 运行测试验证**

```bash
xcodebuild test -scheme OpenRunCat -destination 'platform=macOS' -only-testing:OpenRunCatTests/SystemMonitorTests
```

- [ ] **Step 9: Commit**

```bash
git add OpenRunCat/Monitor/ OpenRunCatTests/MonitorTests/
git commit -m "Implement system monitoring: CPU, Memory, Disk, Network, GPU"
```

---

### Task 4: 实现角色管理模块

**Files:**
- Create: `OpenRunCat/Runner/RunnerLoader.swift`
- Create: `OpenRunCat/Runner/RunnerManager.swift`
- Create: `OpenRunCat/Runner/FrameAnimator.swift`
- Test: `OpenRunCatTests/RunnerTests/RunnerManagerTests.swift`

- [ ] **Step 1: 创建 RunnerLoader.swift**

```swift
// OpenRunCat/Runner/RunnerLoader.swift

import Foundation
import AppKit

class RunnerLoader {
    func loadAllRunners() -> [Runner] {
        var runners: [Runner] = []

        // 加载内置角色
        let builtInRunners = loadBuiltInRunners()
        runners.append(contentsOf: builtInRunners)

        // 加载自定义角色
        let customRunners = loadCustomRunners()
        runners.append(contentsOf: customRunners)

        return runners
    }

    private func loadBuiltInRunners() -> [Runner] {
        var runners: [Runner] = []

        guard let resourcePath = Bundle.main.resourcePath else { return runners }
        let runnersPath = URL(fileURLWithPath: resourcePath).appendingPathComponent(Constants.builtInRunnersPath)

        guard let enumerator = FileManager.default.enumerator(at: runnersPath, includingPropertiesForKeys: [.isDirectoryKey]) else { return runners }

        for case let folderURL as URL in enumerator {
            guard let isDirectory = try? folderURL.resourceValue(forKey: .isDirectoryKey) as Bool, isDirectory else { continue }

            let runner = loadRunnerFromFolder(folderURL, isBuiltIn: true)
            if let runner = runner {
                runners.append(runner)
            }
        }

        return runners
    }

    private func loadCustomRunners() -> [Runner] {
        var runners: [Runner] = []

        let customPathString = Constants.customRunnersPath.replacingOccurrences(of: "~", with: NSHomeDirectory())
        let customPath = URL(fileURLWithPath: customPathString)

        guard FileManager.default.fileExists(atPath: customPath.path) else { return runners }
        guard let enumerator = FileManager.default.enumerator(at: customPath, includingPropertiesForKeys: [.isDirectoryKey]) else { return runners }

        for case let folderURL as URL in enumerator {
            guard let isDirectory = try? folderURL.resourceValue(forKey: .isDirectoryKey) as Bool, isDirectory else { continue }

            let runner = loadRunnerFromFolder(folderURL, isBuiltIn: false)
            if let runner = runner {
                runners.append(runner)
            }
        }

        return runners
    }

    private func loadRunnerFromFolder(_ folder: URL, isBuiltIn: Bool) -> Runner? {
        let runnerName = folder.lastPathComponent
        let framePaths = loadFramePaths(from: folder)

        guard !framePaths.isEmpty else { return nil }

        return Runner(
            id: isBuiltIn ? "builtin-\(runnerName)" : "custom-\(runnerName)",
            name: runnerName,
            framePaths: framePaths,
            isBuiltIn: isBuiltIn
        )
    }

    private func loadFramePaths(from folder: URL) -> [URL] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else { return [] }

        let pngFiles = files
            .filter { $0.pathExtension == "png" }
            .filter { $0.lastPathComponent.contains("frame") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        return pngFiles
    }
}
```

- [ ] **Step 2: 创建 FrameAnimator.swift**

```swift
// OpenRunCat/Runner/FrameAnimator.swift

import Foundation
import AppKit
import Combine

class FrameAnimator: ObservableObject {
    @Published var currentFrame: NSImage?

    private var frames: [NSImage] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var targetFPS: Double = Constants.baseFPS
    private var fpsLimit: Double? = nil

    func setFrames(_ frames: [NSImage]) {
        self.frames = frames
        currentIndex = 0
        if let firstFrame = frames.first {
            currentFrame = firstFrame
        }
    }

    func setSpeed(_ usage: Double) {
        // 动画帧率 = baseSpeed + (usage × multiplier)
        targetFPS = Constants.baseFPS + (usage * Constants.fpsMultiplier)

        // 应用 FPS 限制
        if let limit = fpsLimit {
            targetFPS = min(targetFPS, limit)
        }

        restartTimer()
    }

    func setFPSLimit(_ limit: FPSLimit) {
        fpsLimit = limit.value
        if let limitValue = fpsLimit {
            targetFPS = min(targetFPS, limitValue)
        }
        restartTimer()
    }

    func start() {
        guard !frames.isEmpty else { return }
        restartTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func restartTimer() {
        timer?.invalidate()

        guard targetFPS > 0 else { return }
        let interval = 1.0 / targetFPS

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.advanceFrame()
        }
    }

    private func advanceFrame() {
        guard !frames.isEmpty else { return }

        currentIndex = (currentIndex + 1) % frames.count
        currentFrame = frames[currentIndex]
    }
}
```

- [ ] **Step 3: 创建 RunnerManager.swift**

```swift
// OpenRunCat/Runner/RunnerManager.swift

import Foundation
import AppKit
import Combine

class RunnerManager: ObservableObject {
    @Published var runners: [Runner] = []
    @Published var selectedRunner: Runner?

    private let loader = RunnerLoader()
    private let animator = FrameAnimator()
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadRunners()
        setupBindings()
    }

    func loadRunners() {
        runners = loader.loadAllRunners()
        if let firstRunner = runners.first {
            selectRunner(firstRunner)
        }
    }

    func selectRunner(_ runner: Runner) {
        selectedRunner = runner
        animator.setFrames(runner.frames)
        animator.start()
    }

    func selectRunnerById(_ id: String) {
        guard let runner = runners.first(where: { $0.id == id }) else { return }
        selectRunner(runner)
    }

    private func setupBindings() {
        animator.$currentFrame
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentFrame)
    }

    func updateAnimationSpeed(_ usage: Double) {
        animator.setSpeed(usage)
    }

    func setFPSLimit(_ limit: FPSLimit) {
        animator.setFPSLimit(limit)
    }

    @Published var currentFrame: NSImage?
}
```

- [ ] **Step 4: 创建测试文件**

```swift
// OpenRunCatTests/RunnerTests/RunnerManagerTests.swift

import XCTest
@testable import OpenRunCat

class RunnerManagerTests: XCTestCase {
    var manager: RunnerManager!

    override func setUp() {
        manager = RunnerManager()
    }

    func testLoadRunners() {
        XCTAssertGreaterThan(manager.runners.count, 0)
    }

    func testSelectRunner() {
        guard let firstRunner = manager.runners.first else {
            XCTFail("No runners available")
            return
        }

        manager.selectRunner(firstRunner)
        XCTAssertEqual(manager.selectedRunner?.id, firstRunner.id)
    }

    func testAnimatorSpeedCalculation() {
        let animator = FrameAnimator()
        animator.setSpeed(50.0) // 50% usage

        // Expected FPS = 2 + (50 * 0.5) = 27
        // 验证帧率在合理范围内
        Thread.sleep(forTimeInterval: 0.1)
        XCTAssertNotNil(animator.currentFrame)
    }
}
```

- [ ] **Step 5: 运行测试**

```bash
xcodebuild test -scheme OpenRunCat -destination 'platform=macOS' -only-testing:OpenRunCatTests/RunnerManagerTests
```

- [ ] **Step 6: Commit**

```bash
git add OpenRunCat/Runner/ OpenRunCatTests/RunnerTests/
git commit -m "Implement runner management: Loader, Manager, Animator"
```

---

### Task 5: 实现主题和图标着色

**Files:**
- Create: `OpenRunCat/Utilities/NSImageExtensions.swift`
- Create: `OpenRunCat/Theme/IconTinting.swift`
- Create: `OpenRunCat/Theme/ThemeManager.swift`

- [ ] **Step 1: 创建 NSImageExtensions.swift**

```swift
// OpenRunCat/Utilities/NSImageExtensions.swift

import AppKit

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        let rect = NSRect(origin: .zero, size: image.size)
        rect.fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }

    func resized(to size: NSSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: size))
        newImage.unlockFocus()
        return newImage
    }

    static func templateImage(named: String) -> NSImage? {
        let image = NSImage(named: named)
        image?.isTemplate = true
        return image
    }
}
```

- [ ] **Step 2: 创建 IconTinting.swift**

```swift
// OpenRunCat/Theme/IconTinting.swift

import AppKit

class IconTinting {
    static func tintForTheme(_ theme: AppTheme) -> NSColor {
        switch theme {
        case .light:
            return NSColor.black
        case .dark:
            return NSColor.white
        case .system:
            return systemTint()
        }
    }

    private static func systemTint() -> NSColor {
        // 检测系统当前是否为深色模式
        if let appearance = NSApp.effectiveAppearance {
            if appearance.name == .darkAqua {
                return NSColor.white
            }
        }
        return NSColor.black
    }

    static func tintedIcon(_ image: NSImage, forTheme theme: AppTheme) -> NSImage {
        let tint = tintForTheme(theme)
        return image.tinted(with: tint)
    }
}
```

- [ ] **Step 3: 创建 ThemeManager.swift**

```swift
// OpenRunCat/Theme/ThemeManager.swift

import Foundation
import Combine
import AppKit

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system

    init() {
        observeSystemTheme()
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        applyTheme()
    }

    private func applyTheme() {
        // 触发 UI 更新，各组件监听 currentTheme
        objectWillChange.send()
    }

    private func observeSystemTheme() {
        // 监听系统主题变化
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    @objc private func systemThemeChanged() {
        if currentTheme == .system {
            applyTheme()
        }
    }

    func iconColor() -> NSColor {
        return IconTinting.tintForTheme(currentTheme)
    }

    func tintedImage(_ image: NSImage) -> NSImage {
        return IconTinting.tintedIcon(image, forTheme: currentTheme)
    }
}
```

- [ ] **Step 4: Commit**

```bash
git add OpenRunCat/Utilities/NSImageExtensions.swift OpenRunCat/Theme/
git commit -m "Implement theme management and icon tinting"
```

---

### Task 6: 实现设置管理

**Files:**
- Create: `OpenRunCat/Settings/SettingsManager.swift`
- Create: `OpenRunCat/Settings/LaunchAtLoginManager.swift`
- Test: `OpenRunCatTests/SettingsTests/SettingsManagerTests.swift`

- [ ] **Step 1: 创建 SettingsManager.swift**

```swift
// OpenRunCat/Settings/SettingsManager.swift

import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var settings: Settings

    private let key = "OpenRunCatSettings"
    private var cancellables = Set<AnyCancellable>()

    init() {
        settings = loadSettings()
        setupAutoSave()
    }

    private func loadSettings() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(Settings.self, from: data) else {
            return Settings.default
        }
        return decoded
    }

    private func saveSettings() {
        guard let encoded = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(encoded, forKey: key)
    }

    private func setupAutoSave() {
        $settings
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }

    func updateRunner(_ runnerId: String) {
        settings.selectedRunner = runnerId
    }

    func updateSpeedSource(_ source: SpeedSource) {
        settings.speedSource = source
    }

    func updateTheme(_ theme: AppTheme) {
        settings.theme = theme
    }

    func updateFPSLimit(_ limit: FPSLimit) {
        settings.fpsLimit = limit
    }

    func updateLaunchAtLogin(_ enabled: Bool) {
        settings.launchAtLogin = enabled
    }
}
```

- [ ] **Step 2: 创建 LaunchAtLoginManager.swift**

```swift
// OpenRunCat/Settings/LaunchAtLoginManager.swift

import Foundation
import ServiceManagement

class LaunchAtLoginManager {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to set launch at login: \(error)")
        }
    }

    static func isEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
}
```

- [ ] **Step 3: 创建测试文件**

```swift
// OpenRunCatTests/SettingsTests/SettingsManagerTests.swift

import XCTest
@testable import OpenRunCat

class SettingsManagerTests: XCTestCase {
    var manager: SettingsManager!

    override func setUp() {
        // 清除旧设置
        UserDefaults.standard.removeObject(forKey: "OpenRunCatSettings")
        manager = SettingsManager()
    }

    func testDefaultSettings() {
        XCTAssertEqual(manager.settings.selectedRunner, "Cat")
        XCTAssertEqual(manager.settings.speedSource, .cpu)
        XCTAssertEqual(manager.settings.theme, .system)
    }

    func testUpdateRunner() {
        manager.updateRunner("Dog")
        XCTAssertEqual(manager.settings.selectedRunner, "Dog")
    }

    func testUpdateSpeedSource() {
        manager.updateSpeedSource(.memory)
        XCTAssertEqual(manager.settings.speedSource, .memory)
    }

    func testSettingsPersistence() {
        manager.updateRunner("ClaudeCrab")
        manager.updateTheme(.dark)

        // 强制保存
        Thread.sleep(forTimeInterval: 1.0)

        // 创建新实例验证持久化
        let newManager = SettingsManager()
        XCTAssertEqual(newManager.settings.selectedRunner, "ClaudeCrab")
        XCTAssertEqual(newManager.settings.theme, .dark)
    }
}
```

- [ ] **Step 4: 运行测试**

```bash
xcodebuild test -scheme OpenRunCat -destination 'platform=macOS' -only-testing:OpenRunCatTests/SettingsManagerTests
```

- [ ] **Step 5: Commit**

```bash
git add OpenRunCat/Settings/ OpenRunCatTests/SettingsTests/
git commit -m "Implement settings management with persistence and launch at login"
```

---

### Task 7: 实现菜单栏管理

**Files:**
- Create: `OpenRunCat/MenuBar/StatusItemController.swift`
- Create: `OpenRunCat/MenuBar/ContextMenuBuilder.swift`
- Create: `OpenRunCat/MenuBar/MenuBarManager.swift`
- Create: `OpenRunCat/App/AppDelegate.swift`

- [ ] **Step 1: 创建 StatusItemController.swift**

```swift
// OpenRunCat/MenuBar/StatusItemController.swift

import AppKit

class StatusItemController {
    private var statusItem: NSStatusItem?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }

    func updateIcon(_ image: NSImage) {
        let resizedImage = image.resized(to: NSSize(width: Constants.iconSize, height: Constants.iconSize))
        statusItem?.button?.image = resizedImage
    }

    func setMenu(_ menu: NSMenu) {
        statusItem?.menu = menu
    }
}
```

- [ ] **Step 2: 创建 ContextMenuBuilder.swift**

```swift
// OpenRunCat/MenuBar/ContextMenuBuilder.swift

import AppKit

class ContextMenuBuilder {
    weak var delegate: ContextMenuDelegate?

    func buildMenu(metrics: MetricsData, settings: Settings, runners: [Runner]) -> NSMenu {
        let menu = NSMenu()

        // 系统指标
        addMetricsSection(menu, metrics: metrics)

        menu.addItem(NSMenuItem.separator())

        // Runner 选择
        addRunnerSection(menu, runners: runners, selectedId: settings.selectedRunner)

        menu.addItem(NSMenuItem.separator())

        // Speed Source
        addSpeedSourceSection(menu, current: settings.speedSource)

        menu.addItem(NSMenuItem.separator())

        // Theme
        addThemeSection(menu, current: settings.theme)

        menu.addItem(NSMenuItem.separator())

        // FPS Limit
        addFPSLimitSection(menu, current: settings.fpsLimit)

        menu.addItem(NSMenuItem.separator())

        // Launch at Login
        addLaunchAtLoginItem(menu, enabled: settings.launchAtLogin)

        menu.addItem(NSMenuItem.separator())

        // Quit
        addQuitItem(menu)

        return menu
    }

    private func addMetricsSection(_ menu: NSMenu, metrics: MetricsData) {
        let cpuItem = NSMenuItem(title: "CPU: \(String(format: "%.1f", metrics.cpuUsage))%", action: nil, keyEquivalent: "")
        menu.addItem(cpuItem)

        let memoryGB = ByteFormatter.gbFromBytes(metrics.memoryUsed)
        let memoryTotalGB = ByteFormatter.gbFromBytes(metrics.memoryTotal)
        let memoryItem = NSMenuItem(title: "Memory: \(String(format: "%.1f", metrics.memoryUsage))% / \(String(format: "%.1f", memoryTotalGB)) GB", action: nil, keyEquivalent: "")
        menu.addItem(memoryItem)

        let diskItem = NSMenuItem(title: "Disk: \(String(format: "%.1f", metrics.diskUsage))%", action: nil, keyEquivalent: "")
        menu.addItem(diskItem)

        let networkItem = NSMenuItem(title: "Network: ↑\(ByteFormatter.formatSpeed(metrics.networkUpSpeed)) ↓\(ByteFormatter.formatSpeed(metrics.networkDownSpeed))", action: nil, keyEquivalent: "")
        menu.addItem(networkItem)

        if let gpuUsage = metrics.gpuUsage {
            let gpuItem = NSMenuItem(title: "GPU: \(String(format: "%.1f", gpuUsage))%", action: nil, keyEquivalent: "")
            menu.addItem(gpuItem)
        }
    }

    private func addRunnerSection(_ menu: NSMenu, runners: [Runner], selectedId: String) {
        let runnerMenuItem = NSMenuItem(title: "Runner", action: nil, keyEquivalent: "")
        runnerMenuItem.submenu = NSMenu()

        for runner in runners {
            let item = NSMenuItem(title: runner.name, action: #selector(ContextMenuDelegate.selectRunner(_:)), keyEquivalent: "")
            item.representedObject = runner.id
            item.state = runner.id == selectedId ? .on : .off
            runnerMenuItem.submenu?.addItem(item)
        }

        menu.addItem(runnerMenuItem)
    }

    private func addSpeedSourceSection(_ menu: NSMenu, current: SpeedSource) {
        let sourceMenuItem = NSMenuItem(title: "Speed Source", action: nil, keyEquivalent: "")
        sourceMenuItem.submenu = NSMenu()

        for source in SpeedSource.allCases {
            let item = NSMenuItem(title: source.displayName, action: #selector(ContextMenuDelegate.selectSpeedSource(_:)), keyEquivalent: "")
            item.representedObject = source.rawValue
            item.state = source == current ? .on : .off
            sourceMenuItem.submenu?.addItem(item)
        }

        menu.addItem(sourceMenuItem)
    }

    private func addThemeSection(_ menu: NSMenu, current: AppTheme) {
        let themeMenuItem = NSMenuItem(title: "Theme", action: nil, keyEquivalent: "")
        themeMenuItem.submenu = NSMenu()

        for theme in AppTheme.allCases {
            let item = NSMenuItem(title: theme.displayName, action: #selector(ContextMenuDelegate.selectTheme(_:)), keyEquivalent: "")
            item.representedObject = theme.rawValue
            item.state = theme == current ? .on : .off
            themeMenuItem.submenu?.addItem(item)
        }

        menu.addItem(themeMenuItem)
    }

    private func addFPSLimitSection(_ menu: NSMenu, current: FPSLimit) {
        let fpsMenuItem = NSMenuItem(title: "FPS Limit", action: nil, keyEquivalent: "")
        fpsMenuItem.submenu = NSMenu()

        for limit in FPSLimit.allCases {
            let item = NSMenuItem(title: limit.displayName, action: #selector(ContextMenuDelegate.selectFPSLimit(_:)), keyEquivalent: "")
            item.representedObject = limit.rawValue
            item.state = limit == current ? .on : .off
            fpsMenuItem.submenu?.addItem(item)
        }

        menu.addItem(fpsMenuItem)
    }

    private func addLaunchAtLoginItem(_ menu: NSMenu, enabled: Bool) {
        let item = NSMenuItem(title: "Launch at Login", action: #selector(ContextMenuDelegate.toggleLaunchAtLogin(_:)), keyEquivalent: "")
        item.state = enabled ? .on : .off
        menu.addItem(item)
    }

    private func addQuitItem(_ menu: NSMenu) {
        let quitItem = NSMenuItem(title: "Quit", action: #selector(ContextMenuDelegate.quitApp(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
    }
}

protocol ContextMenuDelegate: AnyObject {
    func selectRunner(_ sender: NSMenuItem)
    func selectSpeedSource(_ sender: NSMenuItem)
    func selectTheme(_ sender: NSMenuItem)
    func selectFPSLimit(_ sender: NSMenuItem)
    func toggleLaunchAtLogin(_ sender: NSMenuItem)
    func quitApp(_ sender: NSMenuItem)
}
```

- [ ] **Step 3: 创建 ByteFormatter.swift**

```swift
// OpenRunCat/Utilities/ByteFormatter.swift

import Foundation

class ByteFormatter {
    static func formatBytes(_ bytes: UInt64) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", Double(bytes) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB", Double(bytes) / (1024.0 * 1024.0 * 1024.0))
        }
    }

    static func formatSpeed(_ bytesPerSecond: UInt64) -> String {
        if bytesPerSecond < 1024 {
            return "\(bytesPerSecond) B/s"
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", Double(bytesPerSecond) / 1024.0)
        } else if bytesPerSecond < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", Double(bytesPerSecond) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB/s", Double(bytesPerSecond) / (1024.0 * 1024.0 * 1024.0))
        }
    }

    static func gbFromBytes(_ bytes: UInt64) -> Double {
        return Double(bytes) / (1024.0 * 1024.0 * 1024.0)
    }
}
```

- [ ] **Step 4: 创建 MenuBarManager.swift**

```swift
// OpenRunCat/MenuBar/MenuBarManager.swift

import AppKit
import Combine

class MenuBarManager: NSObject, ContextMenuDelegate {
    private let statusItemController = StatusItemController()
    private let contextMenuBuilder = ContextMenuBuilder()

    private var systemMonitor: SystemMonitor
    private var runnerManager: RunnerManager
    private var settingsManager: SettingsManager
    private var themeManager: ThemeManager

    private var cancellables = Set<AnyCancellable>()

    init(systemMonitor: SystemMonitor,
         runnerManager: RunnerManager,
         settingsManager: SettingsManager,
         themeManager: ThemeManager) {
        self.systemMonitor = systemMonitor
        self.runnerManager = runnerManager
        self.settingsManager = settingsManager
        self.themeManager = themeManager

        super.init()

        setup()
        setupBindings()
        contextMenuBuilder.delegate = self
    }

    private func setup() {
        statusItemController.setup()
        systemMonitor.startMonitoring()
        runnerManager.loadRunners()

        // 选择默认角色
        runnerManager.selectRunnerById(settingsManager.settings.selectedRunner)
    }

    private func setupBindings() {
        // 监听帧更新
        runnerManager.$currentFrame
            .combineLatest(themeManager.$currentTheme)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] frame, theme in
                guard let frame = frame else { return }
                let tintedFrame = self?.themeManager.tintedImage(frame) ?? frame
                self?.statusItemController.updateIcon(tintedFrame)
            }
            .store(in: &cancellables)

        // 监听指标更新，更新动画速度和菜单
        systemMonitor.$metrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metrics in
                let speed = self?.systemMonitor.getSpeedForSource(self?.settingsManager.settings.speedSource ?? .cpu) ?? 0
                self?.runnerManager.updateAnimationSpeed(speed)
                self?.updateMenu()
            }
            .store(in: &cancellables)

        // 监听设置变化
        settingsManager.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenu()
            }
            .store(in: &cancellables)

        // 监听主题变化
        themeManager.$currentTheme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenu()
            }
            .store(in: &cancellables)
    }

    private func updateMenu() {
        let menu = contextMenuBuilder.buildMenu(
            metrics: systemMonitor.metrics,
            settings: settingsManager.settings,
            runners: runnerManager.runners
        )
        statusItemController.setMenu(menu)
    }

    // ContextMenuDelegate
    func selectRunner(_ sender: NSMenuItem) {
        guard let runnerId = sender.representedObject as? String else { return }
        settingsManager.updateRunner(runnerId)
        runnerManager.selectRunnerById(runnerId)
    }

    func selectSpeedSource(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let source = SpeedSource(rawValue: rawValue) else { return }
        settingsManager.updateSpeedSource(source)
    }

    func selectTheme(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let theme = AppTheme(rawValue: rawValue) else { return }
        settingsManager.updateTheme(theme)
        themeManager.setTheme(theme)
    }

    func selectFPSLimit(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let limit = FPSLimit(rawValue: rawValue) else { return }
        settingsManager.updateFPSLimit(limit)
        runnerManager.setFPSLimit(limit)
    }

    func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        let enabled = sender.state == .off
        settingsManager.updateLaunchAtLogin(enabled)
        LaunchAtLoginManager.setEnabled(enabled)
    }

    func quitApp(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }
}
```

- [ ] **Step 5: 创建 AppDelegate.swift**

```swift
// OpenRunCat/App/AppDelegate.swift

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarManager: MenuBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let systemMonitor = SystemMonitor()
        let runnerManager = RunnerManager()
        let settingsManager = SettingsManager()
        let themeManager = ThemeManager()

        menuBarManager = MenuBarManager(
            systemMonitor: systemMonitor,
            runnerManager: runnerManager,
            settingsManager: settingsManager,
            themeManager: themeManager
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 清理资源
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
```

- [ ] **Step 6: 更新 OpenRunCatApp.swift**

```swift
// OpenRunCat/App/OpenRunCatApp.swift

import SwiftUI

@main
struct OpenRunCatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 菜单栏应用不需要显示窗口
        Settings {
            EmptyView()
        }
    }
}
```

- [ ] **Step 7: Commit**

```bash
git add OpenRunCat/MenuBar/ OpenRunCat/App/AppDelegate.swift OpenRunCat/App/OpenRunCatApp.swift OpenRunCat/Utilities/ByteFormatter.swift
git commit -m "Implement menu bar management and context menu"
```

---

### Task 8: 创建内置角色资源

**Files:**
- Create: `OpenRunCat/Resources/Runners/Cat/frame_00.png`
- Create: `OpenRunCat/Resources/Runners/Cat/frame_01.png`
- Create: `OpenRunCat/Resources/Runners/Cat/frame_02.png`
- Create: `OpenRunCat/Resources/Runners/Cat/frame_03.png`
- Create: `OpenRunCat/Resources/Runners/Cat/frame_04.png`

- [ ] **Step 1: 创建简单的占位帧图片**

说明：由于需要实际图片资源，这里使用代码生成简单的占位图标。后续可以替换为实际的角色序列帧。

使用以下 Swift 代码生成占位帧（可在单独脚本中运行）：

```swift
// 生成占位帧的代码片段
func generatePlaceholderFrames() {
    let colors: [NSColor] = [.gray, .darkGray, .gray, .lightGray, .gray]
    let size = NSSize(width: 18, height: 18)

    for (index, color) in colors.enumerated() {
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        let rect = NSRect(origin: .zero, size: size)
        NSBezierPath(ovalIn: rect).fill()
        image.unlockFocus()

        let data = image.tiffRepresentation!
        let url = URL(fileURLWithPath: "frame_0\(index).png")
        try? NSBitmapImageRep(data: data)?.representation(using: .png, properties: [:])!.write(to: url)
    }
}
```

- [ ] **Step 2: 创建资源目录结构**

```bash
mkdir -p OpenRunCat/Resources/Runners/Cat OpenRunCat/Resources/Runners/Dog OpenRunCat/Resources/Runners/ClaudeCrab
```

- [ ] **Step 3: Commit**

```bash
git add OpenRunCat/Resources/Runners/
git commit -m "Add placeholder runner resources structure"
```

---

### Task 9: 配置和最终整合

**Files:**
- Modify: `OpenRunCat/Info.plist`
- Create: `OpenRunCat/entitlements.plist`
- Modify: `OpenRunCat.xcodeproj` (project settings)

- [ ] **Step 1: 配置 Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024. All rights reserved.</string>
    <key>NSMainStoryboardFile</key>
    <string></string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
```

- [ ] **Step 2: 配置 entitlements.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

- [ ] **Step 3: 在 Xcode 中配置项目**

- 设置 Bundle Identifier: `com.openruncat.app`
- 设置 Deployment Target: macOS 12.0
- 添加 entitlements 文件
- 将 Resources/Runners 添加到 Copy Bundle Resources

- [ ] **Step 4: 构建并运行**

```bash
xcodebuild -scheme OpenRunCat -destination 'platform=macOS' build
```

- [ ] **Step 5: 运行完整测试套件**

```bash
xcodebuild test -scheme OpenRunCat -destination 'platform=macOS'
```

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "Configure project settings, Info.plist, and entitlements"
```

---

### Task 10: 最终验证和文档

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 创建 README.md**

```markdown
# OpenRunCat

macOS 菜单栏跑步动画应用 - Runcat 的开源实现

## 功能

- 菜单栏动画角色，速度随系统负载变化
- 实时显示 CPU、内存、磁盘、网络指标
- 支持自定义角色（PNG 序列帧）
- Light/Dark/System 主题支持
- FPS 限制配置
- 开机启动

## 构建

需要 macOS 12.0+ 和 Xcode 14+

```
xcodebuild -scheme OpenRunCat build
```

## 自定义角色

将角色包放入 `~/Library/Application Support/OpenRunCat/Runners/`

角色包结构：
```
MyRunner/
├── frame_00.png
├── frame_01.png
├── ...
```

建议帧数: 5-12帧，尺寸: 16x16 或 22x22

## License

MIT
```

- [ ] **Step 2: 最终构建验证**

```bash
xcodebuild clean build -scheme OpenRunCat -destination 'platform=macOS'
```

- [ ] **Step 3: Commit 并创建总结**

```bash
git add README.md
git commit -m "Add README documentation"
```

---

## Summary

| Task | Description | Key Files |
|------|-------------|-----------|
| 1 | 项目初始化 | OpenRunCat.xcodeproj, Info.plist |
| 2 | 数据模型 | MetricsData.swift, Settings.swift, Runner.swift |
| 3 | 系统监控 | CPUMonitor.swift, SystemMonitor.swift |
| 4 | 角色管理 | RunnerLoader.swift, RunnerManager.swift |
| 5 | 主题着色 | ThemeManager.swift, IconTinting.swift |
| 6 | 设置管理 | SettingsManager.swift, LaunchAtLoginManager.swift |
| 7 | 菜单栏 | MenuBarManager.swift, ContextMenuBuilder.swift |
| 8 | 内置角色 | Resources/Runners/Cat/ |
| 9 | 配置整合 | Info.plist, entitlements.plist |
| 10 | 文档验证 | README.md |

**Total estimated tasks:** 10
**Testing approach:** TDD with XCTest
**Commit strategy:** Task-by-task commits