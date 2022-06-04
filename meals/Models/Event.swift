//
//  Event.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import Foundation

struct Event: Codable, Identifiable {
    var meal_id: UUID
    var id: UUID = UUID()
    var date: Date = Date()
}
