//
//  ContentView-ViewModel.swift
//  meals
//
//  Created by aclowkey on 20/08/2022.
//

import Foundation
import SwiftUI

@MainActor class Store: ObservableObject {
    private static let dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z"
    private static let mealsFileName = "meals.json"
    private static let eventsFileName = "events.json"
    private static let settingsFileName = "settings.json"

    @Published var meals: [Meal]
    @Published var events: [Event]
    @Published var settings: Settings

    private var imageCache: [Int: UIImage] = [:]

    // For Photo: TODO: Encrypted?
    static var documentsUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    init() {
        meals = Store.loadMeals()

        let loadedEvents: [Event] = Store
                .load(fileName: Store.eventsFileName) ?? []
        events = loadedEvents.sorted(by: { $0.date > $1.date })

        settings = Store.load(fileName: Store.settingsFileName)
            ?? Settings(dataSourceType: .HealthKit)
    }

    init(meals: [Meal], events: [Event], settings: Settings) {
        self.meals = meals
        self.events = events
        self.settings = settings
    }
    
    func glucoseAPI() -> GlucoseAPI {
        switch settings.dataSourceType {
        case .HealthKit:
            return HealthKitUtils()
        case .NightScout:
            return Nightscout()
        case .Debug:
            return Debug()
        }
    }

    // Save a meal, either a new one or an existing one

    // it's based on whether the meal has an ID or not
    // TODO: Error propagation
    func saveMeal(meal: Meal, image: UIImage?) {
        let mealID = meal.id != 0
                ? meal.id
                : (meals.map {
                    $0.id
                }
                .max() ?? 0) + 1
        let mealToSave = Meal(
                id: mealID,
                name: meal.name,
                description: meal.description,
                updatedAt: Date.now
        )
        if (meal.id == 0) {
            self.meals.append(mealToSave)
            save(data: meals, fileName: Store.mealsFileName)
        } else {
            updateMeal(meal: meal)
        }


        if let image = image {
            saveImage(fileName: "photos/\(mealID).jpeg", image: image)
        }
        imageCache[mealID] = image
    }

    func updateMeal(meal: Meal) {
        let mealIndex = meals.firstIndex(where: { $0.id == meal.id })
        guard let mealIndex = mealIndex else {
            return
        }
        meals[mealIndex] = meal
    }

    func deleteMeal(meal: Meal) {
        meals = meals.filter {
            $0.id != meal.id
        }
        save(data: meals, fileName: Store.mealsFileName)
        deleteImage(fileName: "photos/\(meal.id).jpeg")
        imageCache.removeValue(forKey: meal.id)
    }

    // Save an event, either a new one or an existing one.
    func saveSettings(settings: Settings){
        save(data: settings, fileName:Store.settingsFileName)
    }
    // If the event has a 0 ID, it will create a new one starting from the latest or 1
    // TODO: Error propagations
    func saveEvent(event: Event) {
        if (event.id == 0) {
            let largestEventID = events.map {
                        $0.id
                    }
                    .max()
            let newEventID = (largestEventID ?? 0) + 1
            let newEvent = Event(
                    meal_id: event.meal_id,
                    id: newEventID,
                    date: event.date
            )
            events.append(newEvent)
        } else {
            let eventIndex = events.firstIndex(where: { $0.id == event.id })
            guard let eventIndex = eventIndex else {
                return
            }
            events[eventIndex] = event
        }
        save(data: events, fileName: Store.eventsFileName)
        updateMealUpdateDate(event: event)
    }

    func updateMealUpdateDate(event: Event){
        let meal = meals.first{$0.id == event.meal_id}
        guard let meal = meal else {
           return
        }
        updateMeal( meal: Meal(
                    id: meal.id,
                    name: meal.name,
                    description: meal.description,
                    updatedAt: Date.now
            ))
    }

    func deleteEvent(eventId: Int) {
        events = events.filter {
            $0.id != eventId
        }
        save(data: events, fileName: Store.eventsFileName)
    }

    func getMeal(event: Event) -> Meal? {
        meals.first {
            $0.id == event.meal_id
        }
    }

    func getEvents(mealId: Int) -> [Event] {
        events.filter {
            $0.meal_id == mealId
        }
    }

    public func loadImage(meal: Meal) -> UIImage? {
        if let image = imageCache[meal.id] {
            // TODO: Invalidate cache?
            return image
        }
        let image = Store.loadImage(meal: meal)
        imageCache[meal.id] = image
        return image
    }
    
    public static func loadImage(meal: Meal) -> UIImage? {
        let fileURL = Store.documentsUrl.appendingPathComponent("photos/\(meal.id).jpeg")
        return Store.loadImage(fileURL: fileURL)
    }

    private func saveImage(fileName: String, image: UIImage) -> String? {
        let fileURL = Store.documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }

    private func deleteImage(fileName: String) {
        let path = Store.documentsUrl.appendingPathComponent(fileName).path
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    private static func loadMeals() -> [Meal] {
        Store.load(fileName: mealsFileName) ?? []
    }


    public static func loadImage(fileURL: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }


    // TODO: Error propagation

    func save<T: Encodable>(data: T, fileName: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Store.dateFormatter())
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
        decoder.dateDecodingStrategy = .formatted(dateFormatter())

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

    static func dateFormatter() -> DateFormatter {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }

}

struct Settings: Encodable, Decodable {
   var dataSourceType: DatasourceType
   var nightScoutSettings: NightscoutSettings = NightscoutSettings( URL: "", Token: "")
   var developerMode: Bool = false
}

struct NightscoutSettings: Encodable, Decodable {
   var URL: String
   var Token: String
}

enum DatasourceType:  String, Identifiable, Encodable, Decodable, CaseIterable {
   case HealthKit = "HealthKit"
   case NightScout = "NightScout"
   case Debug = "Debug"

   var id: DatasourceType { self }
}
