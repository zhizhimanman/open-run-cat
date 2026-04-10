// OpenRunCat/MenuBar/ContextMenuBuilder.swift

import AppKit

class ContextMenuBuilder {
    weak var delegate: ContextMenuDelegate?

    func buildMenu(metrics: MetricsData, settings: Settings, runners: [Runner]) -> NSMenu {
        let menu = NSMenu()

        // System metrics
        addMetricsSection(menu, metrics: metrics)

        menu.addItem(NSMenuItem.separator())

        // Runner selection
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
        let memoryItem = NSMenuItem(title: "Memory: \(String(format: "%.1f", metrics.memoryUsage))% (\(String(format: "%.1f", memoryGB))/\(String(format: "%.1f", memoryTotalGB)) GB)", action: nil, keyEquivalent: "")
        menu.addItem(memoryItem)

        let diskItem = NSMenuItem(title: "Disk: \(String(format: "%.1f", metrics.diskUsage))%", action: nil, keyEquivalent: "")
        menu.addItem(diskItem)

        let networkItem = NSMenuItem(title: "Network: \(ByteFormatter.formatSpeed(metrics.networkUpSpeed)) / \(ByteFormatter.formatSpeed(metrics.networkDownSpeed))", action: nil, keyEquivalent: "")
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
            item.target = delegate
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
            item.target = delegate
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
            item.target = delegate
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
            item.target = delegate
            fpsMenuItem.submenu?.addItem(item)
        }

        menu.addItem(fpsMenuItem)
    }

    private func addLaunchAtLoginItem(_ menu: NSMenu, enabled: Bool) {
        let item = NSMenuItem(title: "Launch at Login", action: #selector(ContextMenuDelegate.toggleLaunchAtLogin(_:)), keyEquivalent: "")
        item.state = enabled ? .on : .off
        item.target = delegate
        menu.addItem(item)
    }

    private func addQuitItem(_ menu: NSMenu) {
        let quitItem = NSMenuItem(title: "Quit OpenRunCat", action: #selector(ContextMenuDelegate.quitApp(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        quitItem.target = delegate
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