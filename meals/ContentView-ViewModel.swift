//
//  ContentView-ViewModel.swift
//  meals
//
//  Created by aclowkey on 20/08/2022.
//

import Foundation
import SwiftUI

@MainActor class ContentViewViewModel: ObservableObject {
    private static let dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z"
    private static let mealsFileName = "meals.json"
    private static let eventsFileName = "events.json"
    
    @Published var meals: [Meal]
    @Published var events: [Event]
    
    private var imageCache: [Int: UIImage] = [:]
    
    // For Photo: TODO: Encrypted?
    static var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    init() {
        meals = ContentViewViewModel.loadMeals()
        events = ContentViewViewModel.load(fileName: ContentViewViewModel.eventsFileName)
            .sorted(by: {$0.date < $1.date})
    }
    
    init(meals: [Meal], events: [Event]){
        self.meals = meals
        self.events = events
    }
    
    // Save a meal, either a new one or an existing one
    // it's based on whether the meal has an ID or not
    // TODO: Error propagation
    func saveMeal(meal:Meal, image: UIImage?){
        let mealID = meal.id != 0 ? meal.id : (meals.map { $0.id }.max() ?? 0) + 1
        if(meal.id == 0){
            self.meals.append(Meal(
                id: mealID,
                name: meal.name,
                description: meal.description
            ))
        } else {
            let mealIndex = meals.firstIndex(where: {$0.id == meal.id })
            guard let mealIndex = mealIndex else {
                return
            }
            meals[mealIndex] = meal
        }
        save(data: self.meals, fileName: ContentViewViewModel.mealsFileName)
        
        if let image = image {
            saveImage(fileName: "\(mealID).jpeg", image: image)
        }
    }
    
    func deleteMeal(meal: Meal){
        self.meals = self.meals.filter{ $0.id != meal.id}
        save(data: self.meals, fileName: ContentViewViewModel.mealsFileName)
        deleteImage(fileName: "\(meal.id).jpeg")
    }
    
    // Save an event, either a new one or an existing one.
    // If the event has a 0 ID, it will create a new one starting from the latest or 1
    // TODO: Error propagations
    func saveEvent(event:Event){
        if(event.id == 0){
            let largestEventID = events.map { $0.id }.max()
            let newEventID =  (largestEventID ?? 0) + 1
            let newEvent = Event(
                meal_id: event.meal_id,
                id: newEventID,
                date: event.date
            )
            self.events.append(newEvent)
        } else {
            let eventIndex = events.firstIndex(where: {$0.id == event.id })
            guard let eventIndex = eventIndex else {
                return
            }
            events[eventIndex] = event
        }
        save(data: self.events, fileName: ContentViewViewModel.eventsFileName)
    }
    func deleteEvent(eventId: Int){
        self.events = self.events.filter { $0.id != eventId }
        save(data: self.events, fileName: ContentViewViewModel.eventsFileName)
    }
    
    func getMeal(event: Event) -> Meal? {
        return meals.first { $0.id == event.meal_id }
    }
    
    func getEvents(mealId: Int) -> [Event]{
        return events.filter { $0.meal_id == mealId}
    }
    
    public func loadImage(meal: Meal) -> UIImage? {
        if let image = imageCache[meal.id] {
            // TODO: Invalidate cache?
            return image
        }
        let image = ContentViewViewModel.loadImage(meal: meal)
        imageCache[meal.id] = image
        return image
    }
    
    public static func loadImage(meal: Meal) -> UIImage? {
        let fileURL = ContentViewViewModel.documentsUrl.appendingPathComponent("\(meal.id).jpeg")
        return ContentViewViewModel.loadImage(fileURL: fileURL)
    }
    
    private func saveImage(fileName: String, image: UIImage) -> String? {
        let fileURL = ContentViewViewModel.documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
           try? imageData.write(to: fileURL, options: .atomic)
           return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    private func deleteImage(fileName: String){
        let path = ContentViewViewModel.documentsUrl.appendingPathComponent(fileName).path
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    private static func loadMeals() -> [Meal] {
        return ContentViewViewModel.load(fileName: mealsFileName)
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
    func save<T: Encodable>(data: [T], fileName: String){
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(ContentViewViewModel.dateFormatter())
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
    
    static func load<T:Decodable>(fileName: String) -> [T] {
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
                return []
            }
            return try decoder.decode([T].self, from: file.availableData)
        
        } catch {
            return []
        }
    }
    
    static func dateFormatter() -> DateFormatter {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }

}
