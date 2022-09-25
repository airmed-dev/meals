//
// Created by aclowkey on 25/09/2022.
//

import Foundation

class SettingsStore: ObservableObject {
    private static let fileName = "settings.json"
    @Published var settings: Settings

    init() {
        settings = JsonUtils.load(fileName: SettingsStore.fileName)
                ?? Settings(dataSourceType: .HealthKit)
    }

    init(settings: Settings) {
        self.settings = settings
    }

    func saveSettings(settings: Settings) {
        JsonUtils.save(data: settings, fileName: SettingsStore.fileName)
    }
}
