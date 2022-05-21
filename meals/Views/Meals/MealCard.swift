//
//  MealCard.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import SwiftUI

struct MealCard: View {
    @State var meal: Meal
    var body: some View {
        VStack {
            Image(systemName: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
            Text(meal.name)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
}

struct MealCard_Previews: PreviewProvider {
    static var previews: some View {
        MealCard(meal: MealStore.exampleMeal)
    }
}
