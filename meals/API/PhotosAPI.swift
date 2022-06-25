//
//  PhotosAPI.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import Foundation

import SwiftUI

class PhotosAPI {
    static func getPhoto(meal: Meal, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let imageURL = meal.image?.imageURL else {
            completion(.success(nil))
            return
        }
        
        let request = URLRequest(url: URL(string: imageURL)!)
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else {
                completion(.failure(Errors.missingDataField))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    completion(.failure(Errors.notFound))
                    return
                }
                if httpResponse.statusCode != 200 {
                    completion(.failure(Errors.unexpectedError))
                    return
                }
            }
            
            let image = UIImage(data: data)
            guard let image = image else {
                print("Unexpected: no image")
                return
            }
            completion(.success(image))
        }
        
        task.resume()
    }
    
}

struct APIUploadResponse: Codable {
    let id: Int
}


enum Errors: Error {
    case encodingError
    case missingDataField
    case notFound
    case unexpectedError
}
