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
        // Not supported..
        completion(.failure(Errors.unexpectedError))
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
