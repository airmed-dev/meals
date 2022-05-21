//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct MealList: View {
    var mealStore: MealStore = MealStore()
    
    @State var meals: [Meal] = []
    @State var showNewMeal: Bool = false
    @State var selectedMeal: Meal = Meal(id: UUID(), name: "", description: "")
    
    var body: some View {
        NavigationView {
            let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Color.gray.opacity(0.1)
                    ScrollView {
                        LazyVGrid (columns: twoColumns){
                            ForEach(meals, id: \.id) { meal in
                                    HStack {
                                        NavigationLink(destination: {
                                            MealDetails(meal: meal)
                                        }) {
                                            MealCard(meal: meal)
                                                .padding(10)
                                        }
                                    }
                                }
                        }
                    }
                    .navigationTitle("Meals")
                }
                
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
                            meals = newMeals
                        case .failure(let error):
                            print("Failed saving a new meal: \(error)")
                        }
                    }
                })
            }
        }
        .onAppear {
            mealStore.load {  result in
                switch result {
                case .success(let loadedMeals):
                   meals = loadedMeals
                case .failure(let error):
                    print("Failed saving a new meal: \(error)")
                }
            }
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealList(meals:[
            MealStore.exampleMeal,
            MealStore.exampleMeal,
            MealStore.exampleMeal,
            MealStore.exampleMeal,
            MealStore.exampleMeal,
            MealStore.exampleMeal
        ])
            .environmentObject(MealStore(
            ))
    }
}
