//
//  MealList.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI
import Alamofire

struct MealList: View {
    @EnvironmentObject var viewModel: ContentViewViewModel

    @State var displayMealEditor: Bool = false
    @State var displayMealDetails: Bool = false

    @State var selectedMeal: Meal?
    @State var textFilter: String = ""


    func mealGrid(textFilter: String) -> some View {
        let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
        var meals = textFilter == ""
                ? viewModel.meals
                : viewModel.meals.filter {
                    $0.name.contains(textFilter) || $0.description.contains(textFilter)
                }
        meals.sort{ $0.updatedAt.compare($1.updatedAt) == .orderedDescending}
        return LazyVGrid(columns: twoColumns) {
            ForEach(meals, id: \.hashValue) { meal in
                HStack {
                    withAnimation(.easeInOut(duration: 10.0)) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedMeal = meal
                                displayMealDetails = true
                            }
                        }) {
                            MealCard(
                                    font: .headline,
                                    meal: meal,
                                    image: viewModel.loadImage(meal: meal)
                            )
                                    .frame(
                                            width: 150,
                                            height: 150
                                    )
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        }
                    }
                }
            }
        }
    }

    var noMeals: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Image(systemName: "tray.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary.opacity(0.5))
                        .font(.system(size: 30, weight: .ultraLight))
                        .frame(width: 80)

                Text("No meals")
                        .font(.title)

                HStack(alignment: .center) {
                    Spacer()
                    Text("Click on the plus button")
                            .font(.body)
                    Spacer()
                }
            }
                    .position(
                            x: geo.frame(in: .local).midX,
                            y: geo.frame(in: .local).midY
                    )
        }

    }

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.meals.count == 0 {
                    noMeals
                } else {
                    if textFilter != "" {
                        HStack {
                            Text("Searching for")
                            Text(textFilter)
                                    .bold()
                        }
                    }
                    mealGrid(textFilter: textFilter)
                }
            }
                    .searchable(text: $textFilter)
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
                            .environmentObject(viewModel)
                }
                .bottomSheet(isPresented: $displayMealDetails, detents: [.large()]) {
                    MealDetails(meal: selectedMeal!)
                            .environmentObject(viewModel)
                }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        let mealTemplates = (1...3).map { value in
            Meal(id: value, name: "blueberry pie", description: "delicious blueberry")
        }
        Group {
            // No meals
            MealList()
                    .environmentObject(ContentViewViewModel(
                            meals: mealTemplates,
                            events: [])
                    )

            // Some meals
            MealList()
                    .environmentObject(ContentViewViewModel(
                            meals: mealTemplates,
                            events: [])
                    )

            // Skeleton
            MealList()
                    .environmentObject(ContentViewViewModel(
                            meals: [],
                            events: [])
                    )

        }
    }
}
