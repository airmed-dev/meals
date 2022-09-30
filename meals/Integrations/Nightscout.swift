//
//  NightscoutAPI.swift
//  meals
//
//  Created by aclowkey on 09/07/2022.
//

import Foundation


class Nightscout: MetricStore {
    let settings: NightscoutSettings
    
    init(settings: NightscoutSettings){
        self.settings = settings
    }
    
    func getInsulinSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void) {
        completion(.failure(MealsError.generalError("Not implemented")))
    }
    
    func getGlucoseSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void ) {
        completion(.failure(MealsError.generalError("Not implemented")))
    }
}

struct Entry: Codable {
    let _id, device: String
    let date: Double
    let sgv: Double
    let type: String
    let direction: String?
    let dateString: Date
    let utcOffset: Double
    let sysTime: String
    let mills: Int?
}

