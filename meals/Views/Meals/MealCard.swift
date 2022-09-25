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
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            GeometryReader { geo in
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .cornerRadius(10)
                        .matchedGeometryEffect(id: meal.id, in: animation, anchor: .center)
                } else {
                    renderNoimage()
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(meal.name)
                    .font(font)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 2)
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
                    .background(
                        .linearGradient(
                            colors: [.black, .black.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
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
        MealCard(meal: Meal(id:0, name: "Name", description: "Description"))
            .frame(width:200,height:200)
            .background(.red)
    }
}
