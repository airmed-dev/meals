//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI
import Alamofire

struct MealList: View {
    @State var meals: [Meal] = []
    @State var showNewMeal: Bool = false
    
    @State var loading = true
    @State var preview = false
    
    @State var degrees: Double = 45.0
    var animation: Animation {
        Animation.linear(duration: 1)
            .repeatForever()
    }
    
    var body: some View {
        NavigationView {
            let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Color.gray.opacity(0.1)
                    if loading {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(degrees))
                            .onAppear {
                                withAnimation(self.animation){
                                    self.degrees += 180.0
                                }
                            }
                        ScrollView {
                            LazyVGrid (columns: twoColumns){
                                ForEach(0...10, id: \.self) { _ in
                                    RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                                            .frame(width: 150,height: 150)
                                            .background(Color.primary.opacity(0.1))
                                            .padding()
                                }
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVGrid (columns: twoColumns){
                                ForEach(meals, id: \.id) { meal in
                                    HStack {
                                        NavigationLink(destination: {
                                            MealDetails(meal: meal)
                                        }) {
                                            MealCard(meal: meal)
                                                .frame(width: 150,height: 150)
                                                .padding()
                                        }
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
        loading = true
        MealsAPI.getMeals { result in
            switch result {
            case .success(let loadedMeals):
                meals = loadedMeals
            case .failure(let error):
                print("Error loading meals: \(error)")
            }
            loading = false
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealList(meals:[
                Meal(id: 0, name: "Blueberry pie", description: "My tasty blueberries"),
                Meal(id: 1, name: "Blueberry pie", description: "My tasty blueberries"),
                //            Meal(id: UUID(), name: "Blueberry pie", description: "My tasty blueberries"),
                //            Meal(id: UUID(), name: "Blueberry pie", description: "My tasty blueberries"),
                //            Meal(id: UUID(), name: "Blueberry pie", description: "My tasty blueberries"),
            ],
                     loading: false,
                     preview: true
            )
            MealList(meals: [],
                     loading: true,
                     preview: true)
            MealList(meals: [],
                     loading: false,
                     preview: true)
        }
    }
}
