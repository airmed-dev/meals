//
//  ContentView.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var newMealPresented = false
    
    var body: some View {
        // Stores
        let mealStore = MealStore()
        
        // Meal list
        MealList()
            .environmentObject(mealStore)
            .onAppear {
                mealStore.load { result in
                    switch result {
                    case .success(let newMeals):
                        mealStore.meals = newMeals
                    case .failure(let error):
                        print("Failed loading meals: \(error)")
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
