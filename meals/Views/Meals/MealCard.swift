//
//  MealCard.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import SwiftUI

struct MealCard: View {
    var font: Font = Font.caption
    var displayBelow = false
    @State var meal: Meal
    @State var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            GeometryReader { geo in
                VStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .cornerRadius(10)
                    } else {
                        renderNoimage()
                    }
                }
            }
            if !displayBelow {
                HStack(alignment: .firstTextBaseline) {
                    Text(meal.name)
                        .font(font)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.001)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding([.leading, .trailing, .bottom], 2)
                        .background(
                            .linearGradient(
                                stops:[
                                    Gradient.Stop(color: .black, location: 0),
                                    Gradient.Stop(color: .black.opacity(0.2), location: 0.9)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                }
            }
        }
    }
    
    func renderNoimage() -> some View{
        let colors = [ Color(hex: 0xffd89b), Color(hex: 0x19547b)]
        return ZStack {
            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                .opacity(0.5)
            Image(systemName: "photo.circle")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
    }
}

struct MealCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealCard(meal: Meal(id:0, name: "Name", description: "Description"))
                .frame(width:200,height:200)
                .background(.red)
            MealCard(font: .largeTitle, meal: Meal(id:0, name: "Super long name for a meal", description: "Description"))
                .frame(width:200,height:200)
                .background(.red)
            MealCard(displayBelow: true, meal: Meal(id:0, name: "Name", description: "Description"))
                .frame(width:200,height:200)
        }
    }
}
