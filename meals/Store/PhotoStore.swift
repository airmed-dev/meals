//
// Created by aclowkey on 25/09/2022.
//

import SwiftUI
import Foundation

class PhotoStore: ObservableObject {
    private var documentsUrl: URL
    private var imageCache: [Int: UIImage] = [:]

    init(documentsUrl: URL) {
        self.documentsUrl = documentsUrl
    }

    func saveImage(mealID: Int, image: UIImage) {
        let fileURL = getMealPhotoPath(mealID: mealID)
        PhotoStore.saveImage(fileURL: fileURL, image: image)
        imageCache[mealID] = image
    }

    func loadImage(mealID: Int) -> UIImage? {
        if let image = imageCache[mealID] {
            // TODO: Invalidate cache?
            return image
        }
        let fileURL = getMealPhotoPath(mealID: mealID)
        let image = PhotoStore.loadImage(fileURL: fileURL)
        imageCache[mealID] = image
        return image
    }

    func deleteImage(mealID: Int) {
        let fileURL = getMealPhotoPath(mealID: mealID)
        PhotoStore.deleteImage(fileURL: fileURL)
    }

    func getMealPhotoPath(mealID: Int) -> URL {
        documentsUrl.appendingPathComponent("photos/\(mealID).jpeg")
    }

    private static func saveImage(fileURL: URL, image: UIImage) -> String? {
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return ""
        }
        print("Error saving image")
        return nil
    }

    private static func loadImage(fileURL: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

    private static func deleteImage(fileURL: URL) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(atPath: fileURL.path)
        }
    }
}
