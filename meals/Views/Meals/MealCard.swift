//
//  MealCard.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import SwiftUI

struct MealCard: View {
    @State var meal: Meal
    @State var image: Image?
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            if let image = image {
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
               Image(systemName: "photo.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .rotationEffect(Angle(degrees: 90))
            }
            
            Text(meal.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(5)
                .background(.white.opacity(0.9))
        }
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
        .onAppear {
            PhotosAPI.getPhoto(meal: meal) { result in
                switch result {
                case .success(let loadedImage):
                   image = loadedImage
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }
}

struct MealCard_Previews: PreviewProvider {
    static var previews: some View {
        MealCard(meal: MealStore.exampleMeal)
            .frame(height:100)
    }
}
