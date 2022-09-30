//
// Created by aclowkey on 25/09/2022.
//

import Foundation

class SettingsStore: ObservableObject {
    private static let fileName = "settings.json"
    @Published var settings: Settings

    init() {
        settings = Settings(dataSourceType: .Debug)
    }

    init(settings: Settings) {
        self.settings = settings
    }
    
    func load() throws {
         settings = try JsonUtils.load(fileName: SettingsStore.fileName)
                ?? Settings(dataSourceType: .HealthKit)
    }

    func saveSettings(settings: Settings) throws {
        try JsonUtils.save(data: settings, fileName: SettingsStore.fileName)
    }
}
