//
//  Event.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import Foundation

struct Event: Codable, Identifiable, Equatable, Hashable {
    var meal_id: Int
    var id: Int = 0
    var date: Date = Date()
}
