//
//  Meal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import Foundation


struct Meal: Codable {
    var id: UUID
    var name: String
    var description: String
}

struct Event {
    var id: UUID = UUID()
    var date: Date = Date()
}
