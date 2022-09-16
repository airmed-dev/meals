//
//  EventTimelineCard.swift
//  meals
//
//  Created by aclowkey on 15/07/2022.
//

import SwiftUI

struct EventTimelineCard: View {
    @State var image: UIImage? = nil
    var meal: Meal
    var event: Event

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading){
                Text(meal.name)
                    .font(.caption)
                    .fontWeight(.bold)
                if let image = image {
                    Image(uiImage: image).resizable()
                        .frame(height: geo.size.height * 0.75)
                        .scaledToFit()
                        .cornerRadius(15)
                } else {
                    renderNoimage()
                        .scaledToFit()
                        .frame(height: geo.size.height * 0.75)
                        .cornerRadius(15)
                        .shadow(radius: 2)
                }

            }
        }.onAppear {
            image = ContentViewViewModel.loadImage(meal: meal)
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
    
    func formatAsTime(_ date:Date) -> String {
        let hourlyFormatter = DateFormatter()
        hourlyFormatter.dateFormat = "HH:mm"
        return hourlyFormatter.string(from: date)
    }
    
}

struct EventTimelineCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .firstTextBaseline) {
            EventTimelineCard(
                meal: Meal(id: 1, name: "Blueberry ", description: "Blueberry"),
                event: Event(meal_id: 1)
            )
            .frame(height: 200)
            EventTimelineCard(
                meal: Meal(id: 1, name: "Blueberry that has a pretty long name", description: "Blueberry"),
                event: Event(meal_id: 1)
            )
            .frame(height: 200)
        }
    }
}
