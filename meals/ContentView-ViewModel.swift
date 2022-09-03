//
//  ContentView-ViewModel.swift
//  meals
//
//  Created by aclowkey on 20/08/2022.
//

import Foundation
import SwiftUI

@MainActor class ContentViewViewModel: ObservableObject {
    private static let mealsFileName = "meals.json"
    private static let eventsFileName = "events.json"
    
    @Published var meals: [Meal]
    @Published var events: [Event]
    
    // For Photo: TODO: Encrypted?
    static var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    init() {
        meals = ContentViewViewModel.loadMeals()
        events = ContentViewViewModel.load(fileName: ContentViewViewModel.eventsFileName)
    }
    
    init(meals: [Meal], events: [Event]){
        self.meals = meals
        self.events = events
    }
    
    // Save a meal, either a new one or an existing one
    // it's based on whether the meal has an ID or not
    // TODO: Error propagation
    func saveMeal(meal:Meal, image: UIImage?){
        var mealID = meal.id != 0 ? meal.id : (meals.map { $0.id }.max() ?? 0) + 1
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
        save(data: self.meals, fileName: ContentViewViewModel.eventsFileName)
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

    private static func loadMeals() -> [Meal] {
        return ContentViewViewModel.load(fileName: mealsFileName)
    }
    
    public static func loadImage(meal: Meal) -> UIImage? {
        let fileURL = ContentViewViewModel.documentsUrl.appendingPathComponent("\(meal.id).jpeg")
        return loadImage(fileURL: fileURL)
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
        do {
            let data = try JSONEncoder().encode(data)
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
            return try JSONDecoder().decode([T].self, from: file.availableData)
        
        } catch {
            return []
        }
    }

}
