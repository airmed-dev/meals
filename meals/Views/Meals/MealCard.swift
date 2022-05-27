//
//  MealCard.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import SwiftUI

struct MealCard: View {
    @State var meal: Meal
    let photoStore = PhotoStore()
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            photoStore.getImage(meal: meal)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            Text(meal.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(5)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.9))
        }
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
    }
}

struct MealCard_Previews: PreviewProvider {
    static var previews: some View {
        MealCard(meal: MealStore.exampleMeal)
            .frame(height:50)
    }
}
