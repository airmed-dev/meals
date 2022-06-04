//
//  EventListItem.swift
//  meals
//
//  Created by aclowkey on 04/06/2022.
//

import SwiftUI

struct EventListItem: View {
    @State var event: Event
    @State var meal: Meal?
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct EventListItem_Previews: PreviewProvider {
    static var previews: some View {
        EventListItem(event: Event(meal_id: UUID()))
    }
}
