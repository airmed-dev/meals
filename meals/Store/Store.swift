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
    @Published var photoStore: PhotoStore

    static var documentsUrl: URL {
        // For Photo: TODO: Encrypted?
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    init(){
        let photoStore = PhotoStore(documentsUrl: Store.documentsUrl)
        let mealStore = MealStore(photoStore: photoStore)

        self.photoStore = photoStore
        self.mealStore = mealStore
        eventStore = EventStore(mealStore: mealStore)
    }

    init(meals: [Meal], events: [Event]) {
        let photoStore = PhotoStore(documentsUrl: Store.documentsUrl)
        let mealStore = MealStore(photoStore: photoStore, meals: meals)
        let eventStore = EventStore(mealStore: mealStore, events: events)

        self.mealStore = mealStore
        self.photoStore = photoStore
        self.eventStore = eventStore
    }
    
    func load() throws {
        try mealStore.load()
        try eventStore.load()
        try photoStore.load()
    }


    public static func createMetricStore() -> MetricStore {
        let defaults = UserDefaults()
        let datasourceTypeRawValue = defaults.string(forKey: "datasource.type") ?? DatasourceType.HealthKit.rawValue
        let datasourceType: DatasourceType = DatasourceType(rawValue: datasourceTypeRawValue)!
        switch datasourceType {
        case .HealthKit:
            return HealthKitUtils()
        case .NightScout:
            let url = defaults.string(forKey: "datasource.nightscout.url") ?? ""
            let token = defaults.string(forKey: "datasource.nightscout.token") ?? ""
            return Nightscout(url: url, token: token)
        case .Debug:
            return Debug()
        }
    }
}


// TODO: Movee this one as well to JSONStore
class JsonUtils {
    static func save<T: Encodable>(data: T, fileName: String) throws {
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
            throw MealsError.generalError("Failed saving JSON file \(fileName)")
        }
    }

    static func load<T: Decodable>(fileName: String) throws -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        do {
            let url = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
            ).appendingPathComponent(fileName)

            let file = try FileHandle(forReadingFrom: url)
            return try decoder.decode(T.self, from: file.availableData)
        } catch {
            throw MealsError.generalError("Failed loading JSON file \(fileName)")
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
