//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct MealList: View {
    // TODO: This is for testing
    @State var meals: [Meal] = [
                Meal(id:UUID(), name: "Blueberries", description: "My blueberries"),
                Meal(id:UUID(), name: "My other blueberries", description: "My other blue berries"),
            ]
    @State var showNewMeal: Bool = false
    @State var selectedMeal: Meal = Meal(id: UUID(), name: "", description: "")
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    List {
                        ForEach(meals, id: \.id) { meal in
                            HStack {
                                NavigationLink(meal.name, destination: {
                                    MealDetails(meal: meal)
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
                    meals.append(meal)
                })
            }
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealList(meals: [
            Meal(id:UUID(), name: "Blueberries", description: "My blueberries"),
            Meal(id:UUID(), name: "My other blueberries", description: "My other blue berries"),
        ])
    }
}
