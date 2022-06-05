//
//  EventList.swift
//  meals
//
//  Created by aclowkey on 01/06/2022.
//

import Foundation

import SwiftUI

struct EventList: View {
    @State
    var events: [Date: [Event]] = [:]
    
    @State
    var meals: [Meal] = []
    
    @State
    var preview = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                Text("Event count: \(events.count)")
                    .padding()
                
                let eventDates = events.map { $0.key }.sorted(by: >)
                List(eventDates, id: \.self ){ key in
                    let currentEvents = events[key]!
                    
                    Section(header: Text(formatDate(date: key))){
                        ForEach(currentEvents){ event in
                            if let meal = meals.first { $0.id == event.meal_id }{
                                NavigationLink(destination: {
                                    MetricView(meal: meal, event: event, fetchInsulin: true)
                                }) {
                                    EventListItem(event: event, meal: meal)
                                }
                            } else {
                                Text(formatDate(date: event.date))
                                Text("Meal is loading")
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationTitle("Events")
        }
        .onAppear {
            if preview {
                return
            }
            
            EventsAPI.getEvents { result in
                switch result {
                case .success(let loadedEvents):
                    events = Dictionary(grouping: loadedEvents, by: {
                        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: $0.date))!
                    })
                case .failure(let error):
                    print("Error fetching events:\(error)")
                }
            }
            MealsAPI.getMeals { result in
                switch result {
                case .success(let loadedMeals):
                    meals = loadedMeals
                case .failure(let error):
                    print("Error fetching events:\(error)")
                }
            }
            
        }
    }
    
    func formatDate(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
           return "Today"
        }
        if Calendar.current.isDateInYesterday(date){
            return "Yesterday"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        
        return formatter.string(from: date)
    }
    

}

struct EventList_Previews: PreviewProvider {
    
    static var previews: some View {
        let mealUUID = 1
        let today = Date()
        EventList(
            events: [
                today:[
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                ],
                Calendar.current.date(byAdding: .day, value: -1, to: today)!: [
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                ],
                Calendar.current.date(byAdding: .day, value: -2, to: today)!: [
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                ]
            ],
            meals: [
                Meal(id: mealUUID, name: "Test", description: "Test")
            ],
            preview: true
        )
    }
}
