//
// Created by aclowkey on 25/09/2022.
//

import Foundation
import SwiftUI

class MealStore: ObservableObject {
    @Published var meals: [Meal]

    private static let fileName = "meals.json"
    private var photoStore: PhotoStore

    init(photoStore: PhotoStore) {
        self.photoStore = photoStore
        meals = JsonUtils.load(fileName: MealStore.fileName) ?? []
    }

    init(photoStore: PhotoStore, meals: [Meal]) {
        self.photoStore = photoStore
        self.meals = meals
    }

    func getMeal(event: Event) -> Meal? {
        meals.first {
            $0.id == event.meal_id
        }
    }

    func saveMeal(meal: Meal, image: UIImage?) {
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
            JsonUtils.save(data: meals, fileName: MealStore.fileName)
        } else {
            updateMeal(meal: meal)
        }

        if let image = image {
            photoStore.saveImage(mealID: mealID, image: image)
        }
    }

    func updateMeal(meal: Meal) {
        let mealIndex = meals.firstIndex(where: { $0.id == meal.id })
        guard let mealIndex = mealIndex else {
            return
        }
        meals[mealIndex] = meal
    }

    func deleteMeal(meal: Meal) {
        meals = meals.filter {
            $0.id != meal.id
        }
        JsonUtils.save(data: meals, fileName: MealStore.fileName)
        photoStore.deleteImage(mealID: meal.id)
    }

    func updateMealUpdateDate(event: Event) {
        let meal = meals.first {
            $0.id == event.meal_id
        }
        guard let meal = meal else {
            return
        }
        updateMeal(meal: Meal(
                id: meal.id,
                name: meal.name,
                description: meal.description,
                updatedAt: Date.now
        ))
    }
}
