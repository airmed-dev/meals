//
//  Metric.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI


struct MetricSample {
    var date: Date
    var value: Float
    
    init(_ date:Date, _ value:Float){
        self.date = date
        self.value = value
    }
}
