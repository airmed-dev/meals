//
//  EventListItem.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import SwiftUI

struct EventListItem: View {
    @State var event: Event
    @State var meal: Meal
    @State var image: UIImage? = nil
    @State var selected: Bool = false
    
    
    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image).resizable()
                    .clipShape(Circle())
                    .frame(width: 55, height: 55)
            } else {
                Image(systemName: "photo.fill").resizable()
                    .clipShape(Circle())
                    .frame(width: 55, height: 55)
            }
        
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.headline)
                Text(formatDateAsTime(date: event.date))
                    .font(.footnote)
            }
            if selected {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }else {
                Spacer()
            }
            
        }
        .onAppear {
            image = ContentViewViewModel.loadImage(meal: meal)
        }
    }
    
    func formatDateAsTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EventListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            EventListItem(event: Event(meal_id: 1), meal: Meal(id: 1, name: "Blueberry", description: "Blueberry"))
            EventListItem(event: Event(meal_id: 1), meal: Meal(id: 1, name: "Blueberry", description: "Blueberry"),
                          image: UIImage(named:"Blueberry")!, selected: true)
        }
    }
}
