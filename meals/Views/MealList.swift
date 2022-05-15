//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct MealList: View {
    @EnvironmentObject var mealStore: MealStore
    
    @State var showNewMeal: Bool = false
    @State var selectedMeal: Meal = Meal(id: UUID(), name: "", description: "")
    
    var body: some View {
        let eventStore = EventStore()
        
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    List {
                        ForEach(mealStore.meals, id: \.id) { meal in
                            HStack {
                                NavigationLink(meal.name, destination: {
                                    MealDetails(meal: meal)
                                        .environmentObject(eventStore)
                                        .environmentObject(mealStore)
                                })
                            }
                        }
                    }
                }.navigationTitle("Meals")
                
                Button(action: {showNewMeal.toggle() }) {
                   Image(systemName: "plus")
                       .frame(width: 50, height: 50)
                        .background(Color( red: 27, green: 27, blue: 27))
                       .clipShape(Circle())
                }
                .padding(30)
                
            }
            .sheet(isPresented: $showNewMeal) {
                // User creates a new meal
                let mealDraft = Meal(id: UUID(),
                                          name: "",
                                          description: ""
                )
                Text("Create a new meal")
                    .padding()
                MealEditor(meal: mealDraft, onSave: { meal in
                    var newMeals = mealStore.meals
                    newMeals.append(meal)
                    mealStore.save(meals: newMeals) { result in
                        switch result {
                        case .success(let count):
                            print("Save \(count) meals")
                            mealStore.meals = newMeals
                        case .failure(let error):
                            print("Failed saving a new meal: \(error)")
                        }
                    }
                })
            }
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealList()
            .environmentObject(MealStore(
            ))
    }
}
