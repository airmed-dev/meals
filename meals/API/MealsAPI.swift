//
//  MealsAPI.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import Foundation
import UIKit
import Alamofire

class MealsAPI {
    static let baseURL = URL(string: "https://my-meals-api.herokuapp.com/api/meals")!
    
    static func getMeals(completion: @escaping (Result<[Meal],Error>) -> Void ){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "my-meals-api.herokuapp.com"
        urlComponents.path = "/api/meals"
        urlComponents.queryItems = [URLQueryItem(name: "populate", value: "photo")]
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let formatter:DateFormatter = DateFormatter()
                formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
                
                decoder.dateDecodingStrategy = .formatted(formatter)
                let mealResponse = try decoder.decode(MealResponse.self, from: data)
                
                let meals = mealResponse.data.map { m -> Meal in
                    var meal: Meal = Meal(
                        id: m.id,
                        name: m.attributes.name,
                        description: m.attributes.description
                    )
                    if let photo = m.attributes.photo?.data {
                        meal.image = MealImage(imageURL: photo.attributes.url, imageID: photo.id)
                    }
                    return meal
                }
                completion(.success(meals))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
        
    }
    
    static func createMeal(meal: Meal, photo: UIImage?, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let decoder = JSONDecoder()
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        do {
            let mealEncoded = try JSONEncoder().encode(CreateMealParams(name: meal.name , description: meal.description))
            var multipartFormData: (MultipartFormData) -> Void
            if let photo = photo  {
                guard let imageData = photo.jpegData(compressionQuality: 1.0) else {
                    print("Unable to get image jpeg data")
                    completion(.failure(Errors.encodingError))
                    return
                }
                multipartFormData = {multipartFormData in
                    multipartFormData.append(imageData, withName: "files.photo", fileName: meal.id.formatted()+".jpeg", mimeType: "image/jpeg")
                    multipartFormData.append(mealEncoded, withName: "data")
                }
            } else {
                multipartFormData = {multipartFormData in
                    multipartFormData.append(mealEncoded, withName: "data")
                }
            }
            
            AF.upload(
                multipartFormData: multipartFormData,
                to: "https://my-meals-api.herokuapp.com/api/meals",
                headers: [.authorization(bearerToken: TOKEN)]
            )
            .responseDecodable(of: CreateMealResponse.self, decoder: decoder) { response in
                debugPrint("Response: \(response)")
            }
        }
        catch {
            completion(.failure(error))
            return
        }
        
        
        completion(.success(true))
    }
    
    static func deleteMeal(meal:Meal, completion: @escaping (Result<Bool, Error>) -> Void){
        AF.request("https://my-meals-api.herokuapp.com/api/meals/\(meal.id)",
             method: .delete,
            headers: [.authorization(bearerToken: TOKEN)]
        ).responseDecodable(of: CreateMealResponse.self) { result in
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
            // TODO: Delete related events
            completion(.success(true))
        }
    }
    
    static func updateMeal(mealID: Int, meal: Meal, completion: @escaping (Result<Bool, Error>) -> Void){
        let decoder = JSONDecoder()
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let createMealRequest = CreateMealRequest(
            data: CreateMealParams(
                name: meal.name,
                description: meal.description
            )
        )
            
        AF.request("https://my-meals-api.herokuapp.com/api/meals/\(meal.id)",
                   method: .put,
                   parameters: createMealRequest,
                   encoder: JSONParameterEncoder.default,
                   headers: [.authorization(bearerToken: TOKEN),]
        ).responseDecodable(of: CreateMealResponse.self, decoder: decoder) { result in
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
            
            // TODO: Upload a photo
        }
    }
    
}

struct CreateMealResponse: Codable {
    let data: APIMeal
}

struct CreateMealRequest: Codable {
    let data: CreateMealParams
}

struct CreateMealParams: Codable {
    let name: String
    let description: String
}

struct MealResponse: Codable {
    let data: [APIMeal]
    let meta: Meta?
}

struct APIMeal: Codable {
    let id: Int
    let attributes: APIMealSttributes
}

struct APIMealSttributes: Codable {
    let name: String
    let description: String
    let createdAt: Date
    let updatedAt: Date
    let publishedAt: Date
    let photo: APIPhotoWrapper?
}


// Photo types: Move to PhotoStorage?
struct APIPhotoWrapper: Codable {
    let data: APIPhoto?
}

struct APIPhoto: Codable {
    let id: Int
    let attributes: APIPhotoAttributes
}

struct APIPhotoAttributes: Codable {
    let url: String
}


// These are common types, they should be moved to some common folder
struct Meta: Codable{
    let pagination: Pagination
}

struct Pagination: Codable {
    let page: Int
    let pageSize: Int
    let pageCount:Int
    let total: Int
}
