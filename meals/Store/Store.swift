//
//  Store.swift
//  meals
//
//  Created by aclowkey on 20/08/2022.
//

import Foundation
import Combine

@MainActor class Store: ObservableObject {
    @Published var mealStore: MealStore
    @Published var eventStore: EventStore
    @Published var settingsStore: SettingsStore
    @Published var photoStore: PhotoStore
    @Published var metricStore: MetricStore

    static var documentsUrl: URL {
        // For Photo: TODO: Encrypted?
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    init() {
        let photoStore = PhotoStore(documentsUrl: Store.documentsUrl)
        let mealStore = MealStore(photoStore: photoStore)
        let settingsStore = SettingsStore()

        self.photoStore = photoStore
        self.mealStore = mealStore
        self.settingsStore = settingsStore
        eventStore = EventStore(mealStore: mealStore)
        metricStore = Store.createMetricStore(settings: settingsStore.settings)
    }

    init(meals: [Meal], events: [Event], settings: Settings) {
        let photoStore = PhotoStore(documentsUrl: Store.documentsUrl)
        let mealStore = MealStore(photoStore: photoStore, meals: meals)
        let eventStore = EventStore(mealStore: mealStore, events: events)
        let settingsStore = SettingsStore(settings: settings)

        self.mealStore = mealStore
        self.photoStore = photoStore
        self.eventStore = eventStore
        self.settingsStore = settingsStore
        metricStore = Store.createMetricStore(settings: settingsStore.settings)
    }


    private static func createMetricStore(settings: Settings) -> MetricStore {
        switch settings.dataSourceType {
        case .HealthKit:
            return HealthKitUtils()
        case .NightScout:
            return Nightscout(settings: settings.nightScoutSettings)
        case .Debug:
            return Debug()
        }
    }
}


// TODO: Movee this one as well to JSONStore
class JsonUtils {
    static func save<T: Encodable>(data: T, fileName: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        do {
            let data = try encoder.encode(data)
            let url = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
            ).appendingPathComponent(fileName)
            try data.write(to: url)
        } catch {
            return
        }
    }

    static func load<T: Decodable>(fileName: String) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        do {
            let url = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
            ).appendingPathComponent(fileName)

            guard let file = try? FileHandle(forReadingFrom: url) else {
                return nil
            }
            return try decoder.decode(T.self, from: file.availableData)

        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    private static let dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z"
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
