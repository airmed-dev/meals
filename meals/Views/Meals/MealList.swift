//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct MealList: View {
    @EnvironmentObject var mealStore: MealStore
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var photoStore: PhotoStore

    @State var displayMealEditor: Bool = false
    @State var displayMealDetails: Bool = false

    @State var selectedMeal: Meal?
    @State var textFilter: String = ""


    func mealGrid(textFilter: String) -> some View {
        let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
        var meals = textFilter == ""
                ? mealStore.meals
                : mealStore.meals.filter {
            $0.name.contains(textFilter) || $0.description.contains(textFilter)
        }
        meals.sort {
            $0.updatedAt.compare($1.updatedAt) == .orderedDescending
        }
        return LazyVGrid(columns: twoColumns) {
            ForEach(meals, id: \.hashValue) { meal in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedMeal = meal
                            displayMealDetails = true
                        }
                    }) {
                        MealCard(
                            font: .headline,
                            meal: meal,
                            image: try? photoStore.loadImage(mealID: meal.id)
                        )
                        .frame(
                            width: 150,
                            height: 150
                        ).cornerRadius(10)
                    }
            }
        }
        .padding(.leading, 10)
    }

    var body: some View {
        NavigationView {
            VStack {
                if mealStore.meals.count == 0 {
                    NoDataView(
                        title: "No meals",
                        titleFont: .title,
                        prompt: "Click the plus button",
                        iconSize: 100
                    )
                } else {
                    if textFilter != "" {
                        HStack {
                            Text("Searching for")
                            Text(textFilter)
                                .bold()
                        }
                    }
                    ScrollView {
                        mealGrid(textFilter: textFilter)
                    }
                    .searchable(text: $textFilter)
                }
            }
                    .navigationTitle("Meals")
                    
        }
                .overlay {
                    // FAB: TODO: Perhaps add the button to both views?
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { displayMealEditor.toggle() }) {
                                HStack {
                                    Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.white)
                                    Text("Meal")
                                            .foregroundColor(.white)
                                }
                                        .padding(15)
                                        .background(.primary)
                                        .cornerRadius(15)
                                //                    .clipShape(Circle())
                            }
                                    .padding(10)
                        }
                    }
                }
                .bottomSheet(isPresented: $displayMealEditor, detents: [.large()]) {
                    MealEditor()
                            .environmentObject(mealStore)
                }
                .bottomSheet(isPresented: $displayMealDetails, detents: [.large()]) {
                    MealDetails(
                        meal: selectedMeal!,
                        image: try? photoStore.loadImage(mealID: selectedMeal!.id)
                    )
                    .environmentObject(eventStore)
                    .environmentObject(mealStore)
                }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        let mealTemplates = (1...3).map { value in
            Meal(id: value, name: "blueberry pie", description: "delicious blueberry")
        }
        let noMeals = Store(
                meals: [],
                events: []
        )
        let someMeals = Store(
                meals: mealTemplates,
                events: []
        )
        let skeleton = Store(
                meals: [],
                events: []
        )
        Group {
            // No meals
            MealList()
                    .environmentObject(noMeals.photoStore)
                    .environmentObject(noMeals.mealStore)
                    .environmentObject(noMeals.eventStore)

            // Some meals
            MealList()
                    .environmentObject(someMeals.photoStore)
                    .environmentObject(someMeals.mealStore)
                    .environmentObject(someMeals.eventStore)
        }
    }
}
