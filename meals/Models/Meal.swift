//
//  Meal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import Foundation
import SwiftUI


struct Meal: Codable, Hashable {
    var id: Int
    var name: String
    var description: String
    var updatedAt: Date = Date.now

}

