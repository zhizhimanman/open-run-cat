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

        // Select default runner
        runnerManager.selectRunnerById(settingsManager.settings.selectedRunner)

        // Initial menu
        updateMenu()
    }

    private func setupBindings() {
        // Listen to frame updates
        runnerManager.$currentFrame
            .combineLatest(themeManager.$currentTheme)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] frame, theme in
                guard let frame = frame else { return }
                let tintedFrame = self?.themeManager.tintedImage(frame) ?? frame
                self?.statusItemController.updateIcon(tintedFrame)
            }
            .store(in: &cancellables)

        // Listen to metrics updates, update animation speed and menu
        systemMonitor.$metrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metrics in
                let speed = self?.systemMonitor.getSpeedForSource(self?.settingsManager.settings.speedSource ?? .cpu) ?? 0
                self?.runnerManager.updateAnimationSpeed(speed)
                self?.updateMenu()
            }
            .store(in: &cancellables)

        // Listen to settings changes
        settingsManager.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenu()
            }
            .store(in: &cancellables)

        // Listen to theme changes
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
        updateMenu()
    }

    func quitApp(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }
}