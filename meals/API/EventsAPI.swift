//
//  EventsAPI.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import Foundation

class EventsAPI {
    
    static func getEvents(_ completion: @escaping (Result<[Event],Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "my-meals-api.herokuapp.com"
        urlComponents.path = "/api/meal-events"
        urlComponents.queryItems = [URLQueryItem(name: "populate", value: "*")]
        
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            
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
    
    static func saveEvent(event: Event) {
    }
    
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
