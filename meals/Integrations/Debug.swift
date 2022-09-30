//
//  Debug.swift
//  meals
//
//  Created by aclowkey on 24/09/2022.
//

import Foundation

class Debug: MetricStore {
    func getGlucoseSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void) {
        completion(.success(getGlucoseSamples(start: start, end: end)))
    }
    
    func getInsulinSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void) {
        completion(.success(getInsulinSamples(start: start, end: end)))
    }
    
    
    func getGlucoseSamples(start: Date, end: Date) -> [MetricSample] {
        let startPoint = 50 + 100 * Double.random(in:1...3)
        return stride(
                from: start.timeIntervalSince1970,
                to: end.timeIntervalSince1970,
                by: 5*60
            ).map { date in
                return MetricSample(
                    Date(timeIntervalSince1970: date),
                    startPoint + Double.random(in: 0...50)
                )
            }
    }
    
    func getInsulinSamples(start: Date, end: Date) -> [MetricSample] {
        return stride(
            from: start.timeIntervalSince1970,
            to: end.timeIntervalSince1970,
            by: 5*60
        ).map { date in
            let bolus:Double = Double.random(in: 3...5)
            let insulinValue =
                bolus *
                ((end.timeIntervalSince1970 - date) /
                 (end.timeIntervalSince1970 - start.timeIntervalSince1970))
            return MetricSample(
                Date(timeIntervalSince1970: date), insulinValue)
        }
    }
}

