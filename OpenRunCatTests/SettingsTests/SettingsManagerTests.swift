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

        // Force save
        Thread.sleep(forTimeInterval: 1.0)

        // Create new instance to verify persistence
        let newManager = SettingsManager()
        XCTAssertEqual(newManager.settings.selectedRunner, "ClaudeCrab")
        XCTAssertEqual(newManager.settings.theme, .dark)
    }
}