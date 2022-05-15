//
//  MealStore.swift
//  dboard
//
//  Created by aclowkey on 15/04/2022.
//

import Foundation
import SwiftUI

class MealStore: ObservableObject {
    @Published var meals: [Meal] = []
    
    func save(meals: [Meal], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(meals)
                let outFile = try self.fileURL()
                try data.write(to: outFile)
                DispatchQueue.main.async {
                    completion(.success(meals.count))
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


