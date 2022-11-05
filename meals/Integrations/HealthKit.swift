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

class HealthKitUtils: MetricStore {
    
    var healthKitStore = HKHealthStore()
    
    static func requestHKAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitError.notAvailableOnDevice)
            return
        }
        
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let glucose = HKSampleType.quantityType(forIdentifier: .bloodGlucose),
            let insulin = HKSampleType.quantityType(forIdentifier: .insulinDelivery)
        else {
            
            completion(false, HealthkitError.dataTypeNotAvailable)
            return
        }
        
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, glucose, insulin]
        HKHealthStore().requestAuthorization(toShare: [], read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
        
    func getGlucoseSamples(start: Date,
                           end: Date,
                           _ completion: @escaping (Result<[MetricSample], Error>) -> Void ) {
        
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
                withStart: start,
                end: end
            )
            
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
        
    
    func getInsulinSamples(start: Date , end:Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void ) {
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
