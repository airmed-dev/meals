//
//  EventsAPI.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import Foundation
import Alamofire

public struct DeleteError {
    let msg: String
}
    
extension DeleteError: LocalizedError {
    public var errorDescription: String? {
        return msg
    }
}

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
                        meal_id: event.attributes.meal!.data.id,
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
        
        let parameters = CreateEventRequest(data: CreateEventParams(date: event.date, meal: event.meal_id))
        
        AF.request("https://my-meals-api.herokuapp.com/api/meal-events",
             method: .post,
             parameters: parameters,
             encoder: JSONParameterEncoder.json(encoder: encoder),
             headers: [.authorization(bearerToken: TOKEN)]
        ).response { result in
            debugPrint(result)
            guard let response = result.response else {
                print("Error: no response")
                completion(.failure(DeleteError(msg: "No response")))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(DeleteError(msg: "Error: unexpected status code: \(response.statusCode)")))
                return
            }
            completion(.success(true))
        }
    }
    
    static func saveEvent(event: Event, completion: @escaping (Result<Bool, Error>) -> Void){
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        decoder.dateDecodingStrategy = .formatted(formatter)
        let parameters = CreateEventRequest(data: CreateEventParams(
            date: event.date,
            meal: event.meal_id
        ))
        AF.request("https://my-meals-api.herokuapp.com/api/meal-events/\(event.id)",
                   method: .put,
                   parameters: parameters,
                   encoder: JSONParameterEncoder(encoder: encoder),
                   headers: [.authorization(bearerToken: TOKEN),]
        ).responseDecodable(of: CreateEventResponse.self, decoder: decoder) { result in
            debugPrint(result)
            guard let response = result.response else {
                completion(.failure(DeleteError(msg: "No response")))
                return
            }

            guard response.statusCode == 200 else {
                completion(.failure(DeleteError(msg: "Error: unexpected status code: \(response.statusCode)")))
                return
            }
            switch result.result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func deleteEvent(event:Event, completion: @escaping (Result<Bool, Error>) -> Void){
        AF.request("https://my-meals-api.herokuapp.com/api/meal-events/\(event.id)",
                   method: .delete,
                   headers: [.authorization(bearerToken: TOKEN)]
        ).responseDecodable(of: CreateEventResponse.self) { result in
            debugPrint(result)
            guard let response = result.response else {
                print("Error: no response")
                completion(.failure(DeleteError(msg: "Error: no response")))
                return
            }

            guard response.statusCode == 200 else {
                completion(.failure(DeleteError(msg: "Error: unexpected status code: \(response.statusCode)")))
                return
            }
            // TODO: Delete related events
            completion(.success(true))
        }
    }
}

// Mocks
extension EventsAPI {
    static func mockDeleteEvent(event:Event, completion: @escaping (Result<Bool, Error>) -> Void){
        completion(.failure(DeleteError(msg: "API Error: 400: Missing meal id field")))
    }
}

struct CreateEventResponse: Codable {
    let data: APIEvent
}

struct CreateEventRequest: Codable {
    let data: CreateEventParams
}

struct CreateEventParams: Codable {
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
    let meal: APIMealWrapper?
}

struct APIMealWrapper: Codable {
    let data: APIMeal
}
