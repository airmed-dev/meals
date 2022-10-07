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
       let url = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
       ).appendingPathComponent(SettingsStore.fileName)
       if FileManager.default.fileExists(atPath: url.path) {
           settings = try JsonUtils.load(fileName: SettingsStore.fileName) ?? Settings(dataSourceType: .HealthKit)
       } else {
           try saveSettings(settings: settings)
       }

    }

    func saveSettings(settings: Settings) throws {
        try JsonUtils.save(data: settings, fileName: SettingsStore.fileName)
    }
}
