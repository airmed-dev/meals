//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct MealList: View {
    @State var meals: [Meal] = []
    @State var showNewMeal: Bool = false
    
    @State var preview = false
    
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
                }
                .navigationTitle("Meals")
                
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
                let mealDraft = Meal(id: 0,
                                     name: "",
                                     description: ""
                )
                Text("Create a new meal")
                    .padding()
                MealEditor(meal: mealDraft)
                    .onDisappear {
                        loadMeals()
                    }
            }
        }
        .onAppear {
            if preview {
                return
            }
            
            loadMeals()
        }
    }
    
    func loadMeals() {
        MealsAPI.getMeals { result in
            switch result {
            case .success(let loadedMeals):
                meals = loadedMeals
            case .failure(let error):
                print("Error loading meals: \(error)")
            }
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealList(meals:[
            Meal(id: 0, name: "Blueberry pie", description: "My tasty blueberries"),
            Meal(id: 1, name: "Blueberry pie", description: "My tasty blueberries"),
//            Meal(id: UUID(), name: "Blueberry pie", description: "My tasty blueberries"),
//            Meal(id: UUID(), name: "Blueberry pie", description: "My tasty blueberries"),
//            Meal(id: UUID(), name: "Blueberry pie", description: "My tasty blueberries"),
        ],
                 preview: true)
        .environmentObject(MealStore(
        ))
    }
}
