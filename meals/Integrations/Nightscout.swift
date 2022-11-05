//
//  NightscoutAPI.swift
//  meals
//
//  Created by aclowkey on 09/07/2022.
//

import Foundation


class Nightscout: MetricStore {
    var url: String
    var token: String
    
    init(url: String, token: String){
        self.url = url
        self.token = token
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

