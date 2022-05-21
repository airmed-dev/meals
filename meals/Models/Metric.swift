//
//  Metric.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI


struct MetricSample: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var value: Double
    
    init(_ date:Date, _ value:Double){
        self.date = date
        self.value = value
    }
}
