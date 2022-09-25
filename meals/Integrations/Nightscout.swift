//
//  NightscoutAPI.swift
//  meals
//
//  Created by aclowkey on 09/07/2022.
//

import Foundation
import Alamofire


class Nightscout: MetricStore {
    func getInsulinSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void) {
        completion(.failure(MealsError.generalError))
    }
    
    let nightscoutURL = "https://alex-chaplianka-nightscout.herokuapp.com"
    let nightscoutSecret = "fbc2d3e1117252c52c37bf8ca98b5098dad8685e"
    
    func getGlucoseSamples(start: Date, end: Date, _ completion: @escaping (Result<[MetricSample], Error>) -> Void ) {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        

        let paramFormatter = DateFormatter()
        paramFormatter.locale = Locale(identifier: "en_US_POSIX")
        paramFormatter.timeZone = TimeZone(abbreviation: "UTC")
        paramFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let parameters = [
            "find[dateString][$gte]": paramFormatter.string(from: start),
            "find[dateString][$lte]": paramFormatter.string(from: end),
            "count": 2000
        ] as [String : Any]
        
        
        AF.request("\(nightscoutURL)/api/v1/entries.json",
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding(destination: .queryString),
                   headers: [ HTTPHeader(name: "api-secret", value: nightscoutSecret )]
        ).responseDecodable(of: [Entry].self, decoder: decoder) { result in
//            debugPrint(result)
            guard let response = result.response else {
                print("Error: no response")
                completion(.failure(Errors.unexpectedError))
                return
            }
            
            guard response.statusCode == 200 else {
                print("Error: unexpected status code: \(response.statusCode)")
                completion(.failure(Errors.unexpectedError))
                return
            }
            
            switch result.result {
            case .success(let entries):
                let metricSamples = entries.map { entry in
                    MetricSample(entry.dateString, entry.sgv)
                }
                completion(.success(metricSamples))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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

