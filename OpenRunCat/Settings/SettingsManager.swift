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