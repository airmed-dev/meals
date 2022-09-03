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
    @State var displayBottomSheet: Bool = false
    @State var loading = true
    
    
    var mealGrid: some View {
        let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid (columns: twoColumns){
            ForEach(viewModel.meals, id: \.id) { meal in
                HStack {
                    withAnimation(.easeInOut(duration: 10.0)){
                        NavigationLink(destination: {
                            MealDetails(meal: meal)
                        }) {
                            MealCard(meal: meal, image: ContentViewViewModel.loadImage(meal: meal))
                                .frame(width: 150,height: 150)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                           
                                .cornerRadius(10, corners: [.topLeft, .topRight])
                                .padding()
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
        VStack {
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
                    Button(action: {
                        displayBottomSheet = true
                    }){
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(.primary)
                            .clipShape(Circle())
                    }
                    .padding(10)
                }
            }
        }
        .bottomSheet(isPresented: $displayBottomSheet, detents: [.large()]){
            MealEditor()
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
            MealList(
                loading: false
            ).environmentObject(ContentViewViewModel(
                meals: mealTemplates,
                events: [])
            )
            
            // Some meals
            MealList(
                loading: false
            ).environmentObject(ContentViewViewModel(
                meals: mealTemplates,
                events: [])
            )
            
            // Skeleton
            MealList(
                loading: true
            )
            .environmentObject(ContentViewViewModel(
                meals: [],
                events: [])
            )
            
        }
    }
}
