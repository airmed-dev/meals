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

struct RelativeMetricSample: Hashable {
    var offset: TimeInterval
    var value: Double
    
    init(_ offset: TimeInterval, _ value: Double){
        self.offset = offset
        self.value = value
    }
}


struct StatisticsBucket {
    var index: Double
    var min: Double
    var max: Double
    var percentile25: Double
    var percentile75: Double
    var median: Double
}

enum DataType: CustomStringConvertible {
    case Insulin
    case Glucose
    
    var description: String {
        switch self {
        case .Insulin:
            return "Insulin"
        case .Glucose:
            return "Glucose"
        }
    }
}


let ranges: [DataType: (Double, Double)] = [
    .Insulin: (0, 10),
    .Glucose: (40, 400)
]

let glucoseGradientColors = [
    Color(hex: 0x360033),
    Color(hex: 0x0b8793)]

let insulinGradient = [
    Color(hex: 0x135058),
    Color(hex: 0xf1f2b5)
]