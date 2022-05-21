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
            GeometryReader { geometry in
                Image(systemName: "photo.fill")
                    .resizable()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height / 2
                    )
            }
            Text(meal.name)
                .font(.headline)
            Spacer()

        }
    }
}

struct MealCard_Previews: PreviewProvider {
    static var previews: some View {
        MealCard(meal: MealStore.exampleMeal)
    }
}
