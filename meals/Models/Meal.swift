//
//  Meal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import Foundation


struct Meal: Codable {
    var id: Int
    var name: String
    var description: String
    var image: MealImage?
}

struct MealImage: Codable {
    var imageURL: String
    var imageID: Int
}

