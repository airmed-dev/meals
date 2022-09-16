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
    
    
    var mealGrid: some View {
        let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
        return GeometryReader { geo in
            LazyVGrid (columns: twoColumns){
                ForEach(viewModel.meals, id: \.hashValue) { meal in
                    HStack {
                        withAnimation(.easeInOut(duration: 10.0)){
                            Button(action: {
                                withAnimation(.easeInOut){
                                    selectedMeal = meal
                                    displayMealDetails = true
                                }
                            }){
                                MealCard(
                                    font: .headline,
                                    meal: meal,
                                    image: viewModel.loadImage(meal: meal)
                                )
                                .frame(
                                    width: geo.size.width * 0.45,
                                    height: geo.size.width * 0.45
                                )
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                                .cornerRadius(10, corners: [.topLeft, .topRight])
                            }
                        }
                    }
                }
            }
        }
    }
    
    var noMeals: some View {
        return VStack(alignment: .center) {
                Image(systemName: "tray.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary.opacity(0.5))
                    .font(.system(size: 30, weight: .ultraLight))
                    .frame(width: 80)
            
                Text("No meals")
                    .font(.title)
            
                HStack(alignment: .center){
                    Spacer()
                    Text("Click on the plus button")
                        .font(.body)
                    Spacer()
                }
            }
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Meals")
                .font(.largeTitle)
                .padding(2)
            GeometryReader { geo in
                if viewModel.meals.count == 0 {
                   noMeals
                        .position(
                            x: geo.frame(in: .local).midX,
                            y: geo.frame(in: .local).midY
                        )
                } else {
                    mealGrid
                }
            }
        }
        .overlay {
            // FAB: TODO: Perhaps add the button to both views?
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {displayMealEditor.toggle() }) {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                            Text("Create a meal")
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
        .bottomSheet(isPresented: $displayMealEditor, detents: [.large()]){
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
        let mealTemplates = (1...3).map{value in
            return Meal(id: value, name: "blueberry pie", description: "delicious blueberry")
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
