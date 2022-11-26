//
//  MealCard.swift
//  meals
//
//  Created by aclowkey on 21/05/2022.
//

import SwiftUI

struct MealCard: View {
    var title: String = ""
    var titleFont: Font = Font.title
    var subtitle: String = ""
    var subtitleFont: Font = Font.title3
    
    var image: UIImage?
    
    var body: some View {
        GeometryReader { geo in
            // Photo
            ZStack {
                VStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: geo.size.width,
                                height:geo.size.height,
                                alignment: .center
                            )
                            .clipped()
                    } else {
                        renderNoimage()
                    }
                }
                // Titles
                if title != "" {
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                Text(title)
                                    .font(titleFont)
                                Spacer()
                            }
                            
                            if subtitle != "" {
                                HStack {
                                    Text(subtitle)
                                        .font(subtitleFont)
                                    Spacer()
                                }
                            }
                        }
                        .padding([.leading, .trailing,.bottom], 5)
                        .padding([.leading, .trailing,.top], 15)
                        .foregroundColor(.white)
                        .background(
                            .linearGradient(
                                colors: [.black, .black.opacity(0)],
                                startPoint: .bottom,
                                endPoint: .top)
                        )
                    }
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
            MealCard(title:  "Name")
                .frame(width:200,height:200)
                .background(.red)
            
            MealCard( title: "Super long name for a meal",
                      titleFont: .largeTitle
            )
            .frame(width:200,height:200)
            .background(.red)
            
            MealCard()
                .frame(width:200,height:200)
        }
    }
}
