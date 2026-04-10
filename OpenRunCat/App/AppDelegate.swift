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
        // Cleanup resources
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}