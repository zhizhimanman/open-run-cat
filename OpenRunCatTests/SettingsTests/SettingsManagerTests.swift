// OpenRunCatTests/SettingsTests/SettingsManagerTests.swift

import XCTest
@testable import OpenRunCat

class SettingsManagerTests: XCTestCase {
    var manager: SettingsManager!

    override func setUp() {
        // Clear old settings
        UserDefaults.standard.removeObject(forKey: "OpenRunCatSettings")
        manager = SettingsManager()
    }

    func testDefaultSettings() {
        XCTAssertEqual(manager.settings.selectedRunner, "builtin-Cat")
        XCTAssertEqual(manager.settings.speedSource, .cpu)
        XCTAssertEqual(manager.settings.theme, .system)
    }

    func testUpdateRunner() {
        manager.updateRunner("builtin-Dog")
        XCTAssertEqual(manager.settings.selectedRunner, "builtin-Dog")
    }

    func testUpdateSpeedSource() {
        manager.updateSpeedSource(.memory)
        XCTAssertEqual(manager.settings.speedSource, .memory)
    }

    func testSettingsPersistence() {
        manager.updateRunner("builtin-ClaudeCrab")
        manager.updateTheme(.dark)

        // Force save
        Thread.sleep(forTimeInterval: 1.0)

        // Create new instance to verify persistence
        let newManager = SettingsManager()
        XCTAssertEqual(newManager.settings.selectedRunner, "builtin-ClaudeCrab")
        XCTAssertEqual(newManager.settings.theme, .dark)
    }
}