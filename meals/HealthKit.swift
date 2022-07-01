//
//  HealthKit.swift
//  meals
//
//  Created by aclowkey on 18/05/2022.
//

import Foundation
import HealthKit

enum HealthKitUtilsErrors: Error {
    case HealthKitGeneralError
}

class HealthKitUtils {
    var healthKitStore = HKHealthStore()
    
    func getGlucoseSamples(event: Event, hours:TimeInterval, debug:Bool = false, _ completion: @escaping (Result<[MetricSample], Error>) -> Void ) {
        if debug {
            completion(.success(getRandomSamples(for: event)))
        }
        
        guard let glucoseSampleType = HKSampleType.quantityType(forIdentifier: .bloodGlucose) else {
            print("unable to get blood glucose sample type")
            return completion(.failure(HealthKitUtilsErrors.HealthKitGeneralError))
        }
        
        // Fetch preffered units
        healthKitStore.preferredUnits(for: [glucoseSampleType]) { result, error in
            
            let unitType = result[glucoseSampleType]
            guard unitType != nil else {
                print("ERROR: No unit type")
                completion(.failure(HealthKitUtilsErrors.HealthKitGeneralError))
                return
            }
            
            let samplePredicate = HKQuery.predicateForSamples(
                withStart: event.date,
                end: event.date.advanced(by: hours))
            
            let sampleSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            let sampleQuery = HKSampleQuery(
                sampleType: glucoseSampleType,
                predicate: samplePredicate,
                limit: 100,
                sortDescriptors: [sampleSort]
            ) { (query, samples, error) in
                guard let samples = samples,
                      let glucoseSamples = samples as? [HKQuantitySample] else {
                    completion(.failure(HealthKitUtilsErrors.HealthKitGeneralError))
                    print("Empty or invalid samples")
                    return
                }
                let metricSamples = glucoseSamples.map {
                    return MetricSample($0.startDate, $0.quantity.doubleValue(for: unitType!))
                }
                completion(.success(metricSamples))
            }
            
            
            self.healthKitStore.execute(sampleQuery)
        }
    }
        
    
    func getRandomSamples(for event: Event) -> [MetricSample]{
        var glucoseStart = Int.random(in: 50...300)
        var metricSamples:[MetricSample] = []
        for i in 1...36 {
            glucoseStart =
            min(
                max(
                    glucoseStart+Int.random(in: -20...20),
                    50
                ),
                300
            )
            metricSamples.append(MetricSample(event.date.addingTimeInterval(Double(30*i)), Double(glucoseStart)))
        }
        return metricSamples;
    }
    
    func getInsulinSamples(start: Date , end:Date, debug:Bool = false, _ completion: @escaping (Result<[MetricSample], Error>) -> Void ) {
        guard let insulinSampleType = HKSampleType.quantityType(forIdentifier: .insulinDelivery) else {
            print("unable to get insulin sample type")
            return completion(.failure(HealthKitUtilsErrors.HealthKitGeneralError))
        }
        
        // Fetch insulin
        let samplePredicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end
        )
        
        let sampleSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let sampleQuery = HKSampleQuery(
            sampleType: insulinSampleType,
            predicate: samplePredicate,
            limit: 100,
            sortDescriptors: [sampleSort]
        ) { (query, samples, error) in
            guard let samples = samples,
                  let glucoseSamples = samples as? [HKQuantitySample] else {
                completion(.failure(HealthKitUtilsErrors.HealthKitGeneralError))
                print("Empty or invalid samples")
                return
            }
            let metricSamples = glucoseSamples.map {
                return MetricSample($0.startDate, $0.quantity.doubleValue(for: HKUnit.init(from: "IU")))
            }
            completion(.success(metricSamples))
        }
        
        
        self.healthKitStore.execute(sampleQuery)
    }
        
}
