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
        // Trigger UI update, components observe currentTheme
        objectWillChange.send()
    }

    private func observeSystemTheme() {
        // Listen for system theme changes
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