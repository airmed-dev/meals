//
//  MealStorage.swift
//  meals
//
//  Created by aclowkey on 05/08/2022.
//

import Foundation
import UIKit


protocol MealStorage {
    func save(meal: Meal, _ completion: (@escaping (Error) -> Void))
    func update(mealID: Int, meal: Meal, _ completion: (Error) -> Void)
    func delete(mealID: Int)
}

protocol EventStorage {
    func save(event: Event)
    func update(eventID: Int, event: Event)
    func delete(eventID: Int, event: Event)
}

protocol PhotoStorage {
    func save(mealID: Int, image: UIImage)
    func get(mealID: Int)
}



