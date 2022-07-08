//
//  EventsAPI.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import Foundation
import Alamofire

class EventsAPI {
    
    static func getEvents(mealID: Int?, _ completion: @escaping (Result<[Event],Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "my-meals-api.herokuapp.com"
        urlComponents.path = "/api/meal-events"
        urlComponents.queryItems = [
            URLQueryItem(name: "populate", value: "*")
        ]
        
        if let mealID = mealID {
            urlComponents.queryItems?.append(
                URLQueryItem( name: "filters[meal][id][$eq]", value: String(mealID))
            )
        }
        
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let formatter:DateFormatter = DateFormatter()
                formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let eventResponse = try decoder.decode(EventResponse.self, from: data)
                let events = eventResponse.data.map { event in
                    Event(
                        meal_id: event.attributes.meal.data.id,
                        id: event.id,
                        date: event.attributes.date
                    )
                }
                completion(.success(events))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
        
    }
    
    static func createEvent(event:Event, completion: @escaping (Result<Bool, Error>) -> Void){
        let encoder = JSONEncoder()
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        let parameters = CreateEventRequest(data: CreateEventData(date: event.date, meal: event.meal_id))
        
        AF.request("https://my-meals-api.herokuapp.com/api/meal-events",
             method: .post,
             parameters: parameters,
             encoder: JSONParameterEncoder.json(encoder: encoder),
             headers: [.authorization(bearerToken: TOKEN)]
        ).response { result in
            debugPrint(result)
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
            completion(.success(true))
        }
    }
}

struct CreateEventRequest: Codable {
    let data: CreateEventData
}

struct CreateEventData: Codable {
    let date: Date
    let meal: Int
}

struct EventResponse: Codable {
    let data: [APIEvent]
    let meta: Meta
}

struct APIEvent: Codable {
    let id: Int
    let attributes: APIEventAttributes
}

struct APIEventAttributes: Codable {
    let date: Date
    let createdAt: Date
    let updatedAt: Date
    let publishedAt: Date
    let meal: APIMealWrapper
}

struct APIMealWrapper: Codable {
    let data: APIMeal
}
