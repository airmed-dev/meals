//
//  Debug.swift
//  meals
//
//  Created by aclowkey on 24/09/2022.
//

import Foundation

class Debug: MetricStore {
    var noData = false
    
    init(noData: Bool = false){
        self.noData = noData
    }
    
    func getGlucoseSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void) {
        completion(.success(getGlucoseSamples(start: start, end: end)))
    }

    func getInsulinSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void) {
        completion(.success(getInsulinSamples(start: start, end: end)))
    }


    func getGlucoseSamples(start: Date, end: Date) -> [MetricSample] {
        if noData {
            return []
        }
        let minValue = 50.0
        let maxValue = 500.0
        let startPoint = minValue + 100 * Double.random(in: 0...2)
        var point = startPoint
        var samples: [MetricSample] = []
        stride(
                from: start.timeIntervalSince1970,
                to: end.timeIntervalSince1970,
                by: 5 * 60
        ).forEach { date in
            samples.append(MetricSample(
                    Date(timeIntervalSince1970: date), point
            ))
            point = max(min(point + Double.random(in: -15...15), maxValue), minValue)
        }

        return samples
    }

    func getInsulinSamples(start: Date, end: Date) -> [MetricSample] {
        if noData {
            return []
        }
        // Random sample at start+insulinActiveDuration
        let startAfterLastInsulin = start.addingTimeInterval(insulinActiveDuration)
        var insulinDelivery =  [
            MetricSample(startAfterLastInsulin, Double.random(in: 1...5))
        ]
        
        // Randomly inject before start time 0.1 probablity
        let deliveryBeforeStart = start.addingTimeInterval(insulinActiveDuration/2)
        if Int.random(in: 1...10) > 9 {
            insulinDelivery.insert(MetricSample(deliveryBeforeStart, Double.random(in: 1...5)), at: 0)
        }
        return insulinDelivery
    }
}

