---
name: OpenRunCat Design
description: macOS 菜单栏跑步动画应用设计规范
---

# OpenRunCat Design Specification

## 项目概述

开发一个 macOS 菜单栏应用，显示跑步动画角色，动画速度根据系统指标（CPU/内存等）动态变化。支持自定义角色、多指标监控、主题切换。

**技术栈：** Swift + SwiftUI + AppKit（菜单栏需要）

**目标平台：** macOS 12.0+

---

## 核心功能

1. **菜单栏动画图标** — 显示跑步角色帧动画，速度映射到系统负载
2. **右键菜单** — 实时显示系统指标 + 设置选项
3. **多系统指标监控** — CPU、GPU、内存、磁盘、网络
4. **角色系统** — 内置角色 + 本地自定义角色加载
5. **主题支持** — Light/Dark/System 三种主题
6. **FPS 限制** — 可配置帧率上限（None/30/60）
7. **开机启动** — 支持登录时自动启动

---

## 架构设计

### 模块划分

```
OpenRunCat/
├─ App/
│  ├─ AppDelegate.swift          — 应用生命周期、菜单栏初始化
│  ├─ OpenRunCatApp.swift        — SwiftUI App 入口
│  └─ Constants.swift            — 全局常量
│
├─ MenuBar/
│  ├─ MenuBarManager.swift       — 菜单栏图标管理、动画循环
│  ├─ StatusItemController.swift — NSStatusItem 封装
│  └─ ContextMenuBuilder.swift   — 右键菜单构建
│
├─ Monitor/
│  ├─ SystemMonitor.swift        — 系统指标采集协调器
│  ├─ CPUMonitor.swift           — CPU 使用率
│  ├─ MemoryMonitor.swift        — 内存使用情况
│  ├─ DiskMonitor.swift          — 磁盘读写/使用率
│  ├─ NetworkMonitor.swift       — 网络吞吐量
│  └─ GPUMonitor.swift           — GPU 使用率（Mac 支持）
│
├─ Runner/
│  ├─ RunnerManager.swift        — 角色加载、帧动画播放
│  ├─ Runner.swift               — 角色模型定义
│  ├─ RunnerLoader.swift         — 角色包扫描加载
│  └─ FrameAnimator.swift        — 帧动画控制器
│
├─ Settings/
│  ├─ SettingsManager.swift      — 用户偏好存储（UserDefaults）
│  ├─ Settings.swift             — 设置数据模型
│  └─ LaunchAtLoginManager.swift — 开机启动注册
│
├─ Theme/
│  ├─ ThemeManager.swift         — 主题管理
│  ├─ Theme.swift                — 主题枚举（Light/Dark/System）
│  └─ IconTinting.swift          — 图标着色处理
│
├─ UI/
│  ├─ MetricsView.swift          — 菜单中的指标显示组件
│  └─ RunnerPickerView.swift     — 角色选择器
│
└─ Resources/
   └─ Runners/                   — 内置角色包目录
      ├─ Cat/
      ├─ Dog/
      └─ ClaudeCrab/
```

### 数据流

```
┌─────────────────┐     ┌─────────────────┐
│  SystemMonitor  │────▶│  MetricsData    │
│  (1s interval)  │     │  (CPU/Mem/...)  │
└─────────────────┘     └─────────────────┘
                               │
                               ▼ SpeedSource 选择
┌─────────────────┐     ┌─────────────────┐
│  FrameAnimator  │────▶│  MenuBarManager │
│  (frame timing) │     │  (icon update)  │
└─────────────────┘     └─────────────────┘
```

---

## 核心组件设计

### 1. MenuBarManager

职责：
- 管理 NSStatusItem 的图标显示
- 控制帧动画播放速度（根据 SpeedSource 映射）
- 构建并显示右键菜单

关键方法：
- `updateIcon(frame: NSImage)` — 更新当前帧图标
- `setAnimationSpeed(speed: Double)` — 设置动画帧率
- `buildContextMenu()` — 构建右键菜单

### 2. SystemMonitor

职责：
- 定时采集各系统指标
- 提供统一的指标数据接口

采集频率：1 秒

数据结构：
```swift
struct MetricsData {
    var cpuUsage: Double          // 0-100%
    var memoryUsage: Double       // 0-100%
    var memoryUsed: UInt64        // bytes
    var memoryTotal: UInt64       // bytes
    var diskUsage: Double         // 0-100%
    var diskReadSpeed: UInt64     // bytes/s
    var diskWriteSpeed: UInt64    // bytes/s
    var networkUpSpeed: UInt64    // bytes/s
    var networkDownSpeed: UInt64  // bytes/s
    var gpuUsage: Double?         // 0-100% or nil (unavailable)
}
```
注：GPU 监控在部分 Mac 上不可用（如老款机型），返回 nil 时菜单不显示 GPU 行。
```

### 3. RunnerManager

职责：
- 加载内置和自定义角色包
- 提供角色帧序列
- 根据主题处理图标着色

角色模型：
```swift
struct Runner: Identifiable {
    let id: String              // 角色唯一标识
    let name: String            // 显示名称
    let frameCount: Int         // 帧数
    let frames: [NSImage]       // 帧序列（内存加载）
    let framePaths: [URL]       // 帧文件路径（用于持久化）
    let isBuiltIn: Bool         // 是否内置
}
```
注：NSImage 不支持 Codable，持久化使用 framePaths，运行时加载到 frames。
```

### 4. SettingsManager

职责：
- 存储用户偏好（当前角色、SpeedSource、主题、FPS限制）
- 管理开机启动状态

设置模型：
```swift
struct Settings: Codable {
    var selectedRunner: String
    var speedSource: SpeedSource    // CPU, GPU, Memory
    var theme: AppTheme             // Light, Dark, System
    var fpsLimit: FPSLimit          // None, 30, 60
    var launchAtLogin: Bool
}
```

---

## 角色系统设计

### 角色包结构

每个角色是一个文件夹，包含 PNG 序列帧：

```
RunnerName/
├─ frame_00.png   (建议尺寸: 22x22 或 16x16)
├─ frame_01.png
├─ frame_02.png
├─ ...
└─ manifest.json  (可选，包含角色元信息)
```

### 角色存储位置

1. **内置角色** — `App Bundle/Resources/Runners/`
2. **自定义角色** — `~/Library/Application Support/OpenRunCat/Runners/`

应用启动时扫描两个目录，合并角色列表。

### manifest.json 格式（可选）

```json
{
  "name": "Claude Crab",
  "frameCount": 8,
  "author": "User",
  "version": "1.0"
}
```

---

## 主题与图标着色

- **Light Theme** — 深色图标
- **Dark Theme** — 浅色图标
- **System Theme** — 根据 macOS 系统设置自动切换

图标着色使用 NSImage 的 `tint(color:)` 扩展方法。

---

## 右键菜单结构

```
┌─────────────────────────────────────┐
│  CPU: 45.2%                         │
│  Memory: 62.5% / 10.0 GB            │
│  Disk: 78% (R: 2.1 MB/s W: 1.5 MB/s)│
│  Network: ↑ 150 KB/s ↓ 420 KB/s     │
│  GPU: 12% (if available)            │
├─────────────────────────────────────┤
│  Runner                             │
│  ├─ Cat ✓                           │
│  ├─ Dog                             │
│  ├─ Claude Crab                     │
│  └─ Custom Runner 1                 │
├─────────────────────────────────────┤
│  Speed Source                       │
│  ├─ CPU ✓                           │
│  ├─ Memory                          │
│  └─ GPU                             │
├─────────────────────────────────────┤
│  Theme                              │
│  ├─ Light                           │
│  ├─ Dark ✓                          │
│  └─ System                          │
├─────────────────────────────────────┤
│  FPS Limit                          │
│  ├─ None ✓                          │
│  ├─ 30                              │
│  └─ 60                              │
├─────────────────────────────────────┤
│  ☑ Launch at Login                  │
├─────────────────────────────────────┤
│  Quit                               │
└─────────────────────────────────────┘
```

---

## 速度映射算法

动画帧率 = baseSpeed + (usage × multiplier)

**默认值（可后续调整）：**
- baseSpeed: 2 fps（最低帧率）
- multiplier: 0.5（100%负载时额外增加 50 fps）

示例：
- CPU 0% → 2 fps（慢走）
- CPU 50% → 27 fps（正常跑）
- CPU 100% → 52 fps（冲刺）

---

## 后续扩展功能（不在 MVP 范围）

1. **Endless Runner 小游戏** — 点击角色进入跑酷小游戏
2. **在线角色商店** — 下载社区分享的角色包
3. **角色编辑器** — 内置角色创建工具
4. **多语言支持** — 中文、英文、日文等

---

## 文件清单（核心文件）

以下为必须实现的核心文件，其他辅助文件在实现计划中详细列出。

| 文件 | 职责 |
|------|------|
| AppDelegate.swift | 应用入口、菜单栏初始化 |
| MenuBarManager.swift | 菜单栏图标和动画管理 |
| SystemMonitor.swift | 系统指标采集 |
| RunnerManager.swift | 角色加载和播放 |
| SettingsManager.swift | 用户偏好存储 |
| ThemeManager.swift | 主题切换 |
| Constants.swift | 全局常量定义 |

---

## 技术要点

1. **菜单栏应用** — 使用 NSStatusItem，无 Dock 图标（LSUIElement=true）
2. **帧动画** — Timer 驱动，帧率可变
3. **系统指标采集** — 使用 Foundation/Cocoa API（无需第三方库）
4. **开机启动** — 使用 ServiceManagement framework
5. **SwiftUI + AppKit 混合** — 菜单用 AppKit，设置面板可用 SwiftUI