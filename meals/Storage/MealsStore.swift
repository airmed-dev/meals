//
//  MealStore.swift
//
//  Created by aclowkey on 15/04/2022.
//

import Foundation
import SwiftUI

class MealStore: ObservableObject {
    @Published var meals: [Meal] = []
    static let exampleMeal = Meal(
           id: 14,
           name: "Pitaya Smoothie Bowl",
           description: "Add the frozen pitaya, banana, strawberries and coconut water into a high powered blender. Blend on high for one minute, until well combined. jour your pitaya smoothie into a bowl and add your toppings."
    )
    
    static func newExampleMeal() -> Meal {
        var newExampleMeal = exampleMeal
        newExampleMeal.id = Int.random(in: 1...100)
        return newExampleMeal
    }
    
    func save(meals: [Meal], completion: @escaping (Result<[Meal], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let deduplicatedMeals = Array(Dictionary(grouping: meals, by: {$0.id}).values)
                let data = try JSONEncoder().encode(deduplicatedMeals)
                let outFile = try self.fileURL()
                try data.write(to: outFile)
                DispatchQueue.main.async {
                    completion(.success(meals))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func load(completion: @escaping (Result<[Meal], Error>)->Void){
        DispatchQueue.global(qos: .background).async {
            do{
                let fileURL = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                self.meals = try JSONDecoder().decode([Meal].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(self.meals))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        .appendingPathComponent("meals.data")
    }
}


