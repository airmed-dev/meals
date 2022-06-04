//
//  PhotoStore.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import Foundation
import PhotosUI
import SwiftUI

class PhotoStore {
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getImage(meal: Meal) -> Image {
        guard let image = load(fileName: "\(meal.id).jpg") else {
            return Image(systemName: "photo.fill")
        }
        return Image(uiImage: image)
    }
    
    func getImage(event: Event) -> Image {
        return getImage(meal: Meal(id: event.meal_id, name: "", description: ""))
    }
    
    func saveImage(meal: Meal, image: UIImage) {
        save(fileName: "\(meal.id).jpg" , image: image)
    }
    
    private func save(fileName: String, image: UIImage) -> String? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
           try? imageData.write(to: fileURL, options: .atomic)
           return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }

    private func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

}
