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
        // Detect if system is currently in dark mode
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