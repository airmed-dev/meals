//
// Created by aclowkey on 25/09/2022.
//

import Foundation
import SwiftUI

class MealStore: ObservableObject {
    @Published var meals: [Meal]

    private static let fileName = "meals.json"
    private var photoStore: PhotoStore

    init(photoStore: PhotoStore){
        self.photoStore = photoStore
        self.meals = []
    }

    init(photoStore: PhotoStore, meals: [Meal]) {
        self.photoStore = photoStore
        self.meals = meals
    }
    
    func load() throws {
        let url = try FileManager.default.url(
                 for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: false
        ).appendingPathComponent(MealStore.fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            meals = try JsonUtils.load(fileName: MealStore.fileName) ?? []
        } else {
            try JsonUtils.save(data: meals,  fileName:MealStore.fileName)
        }
    }
    
    func getMeal(event: Event) -> Meal? {
        meals.first {
            $0.id == event.meal_id
        }
    }

    func saveMeal(meal: Meal, image: UIImage?) throws {
        let mealID = meal.id != 0
                ? meal.id
                : (meals.map {
                    $0.id
                }
                .max() ?? 0) + 1
        let mealToSave = Meal(
                id: mealID,
                name: meal.name,
                description: meal.description,
                updatedAt: Date.now
        )
        if (meal.id == 0) {
            meals.append(mealToSave)
            try JsonUtils.save(data: meals, fileName: MealStore.fileName)
        } else {
            try updateMeal(meal: mealToSave)
        }

        if let image = image {
            try photoStore.saveImage(mealID: mealID, image: image)
        }
    }

    func updateMeal(meal: Meal) throws {
        let mealIndex = meals.firstIndex(where: { $0.id == meal.id })
        guard let mealIndex = mealIndex else {
            return
        }
        meals[mealIndex] = meal
        try JsonUtils.save(data: meals, fileName: MealStore.fileName)
    }

    func deleteMeal(meal: Meal) throws {
        meals = meals.filter {
            $0.id != meal.id
        }
        try JsonUtils.save(data: meals, fileName: MealStore.fileName)
        try photoStore.deleteImage(mealID: meal.id)
    }

    func updateMealUpdateDate(event: Event) throws {
        let meal = meals.first {
            $0.id == event.meal_id
        }
        guard let meal = meal else {
            return
        }
        try updateMeal(meal: Meal(
                id: meal.id,
                name: meal.name,
                description: meal.description,
                updatedAt: Date.now
        ))
    }
}
