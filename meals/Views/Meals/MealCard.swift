//
//  MealCard.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import SwiftUI

struct MealCard: View {
    var font: Font = Font.caption
    @State var meal: Meal
    @State var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            GeometryReader { geo in
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                } else {
                    renderNoimage()
                }
            }
            
            Text(meal.name)
                .font(font)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(10)
                .background(.linearGradient(colors: [.black, .black.opacity(0)], startPoint: .bottom, endPoint: .top))
        }
    }
    
    func renderNoimage() -> some View{
        let colors = [Color(hex:0x424242), Color(hex:0x002266)]
        return ZStack {
            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            Image(systemName: "photo.circle")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
    }
}

struct MealCard_Previews: PreviewProvider {
    static var previews: some View {
        MealCard(meal: MealStore.exampleMeal)
            .frame(width:200,height:200)
            .background(.red)
    }
}
