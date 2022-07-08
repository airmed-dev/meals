//
//  EventList.swift
//  meals
//
//  Created by aclowkey on 01/06/2022.
//

import Foundation

import SwiftUI

struct EventList: View {
    @State var events: [Date: [Event]] = [:]
    
    @State var selectedEvent: Event?
    @State var meals: [Meal] = []
    
    @State var preview = false
    
    @State var loadingEvents = true
    @State var loadingMeals = true
    
    var body: some View {
        NavigationView {
            if loadingMeals || loadingEvents {
                // Skeleton
                ZStack {
                   ProgressView()
                }
            } else {
                // Actual view
                VStack(alignment: .leading){
                    HStack {
                        Text("Event count: \(events.count)")
                            .padding()
                        Spacer()
                        if let se = selectedEvent {
                            NavigationLink(destination: {
                                MetricView(meal:meals.first{$0.id == se.meal_id}!, event: se )
                            } ){
                                Text("See event")
                            }
                        }
                        
                    }
                    
                    GeometryReader{ geo in
                        VStack(alignment: .center){
                            if let se = selectedEvent {
                                withAnimation(.easeIn) {
                                    MetricGraph(event: se, dataType: .Glucose)
                                }
                            } else {
                                HStack(alignment: .center) {
                                    Text("No event selected")
                                }
                                .frame(width: geo.size.width, height: geo.size.height)
                                .background(Color(.systemGroupedBackground))
                            }
                        }
                    }
                    .frame(height: 200)
                    
                    Text("Events")
                        .font(.headline)
                        .padding()
                    let eventDates = events.map { $0.key }.sorted(by: >)
                    List(eventDates, id: \.self ){ key in
                        let currentEvents = events[key]!
                        
                        Section(header: Text(formatDate(date: key))){
                            ForEach(currentEvents){ event in
                                if let meal = meals.first { $0.id == event.meal_id }{
                                    EventListItem(event: event, meal: meal)
                                        .onTapGesture {
                                            selectedEvent = event
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
        }
        .onAppear {
            if preview {
                return
            }
            
            EventsAPI.getEvents(mealID: nil) { result in
                switch result {
                case .success(let loadedEvents):
                    events = Dictionary(grouping: loadedEvents, by: {
                        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: $0.date))!
                    })
                case .failure(let error):
                    print("Error fetching events:\(error)")
                }
                loadingEvents = false
            }
            MealsAPI.getMeals { result in
                switch result {
                case .success(let loadedMeals):
                    meals = loadedMeals
                case .failure(let error):
                    print("Error fetching events:\(error)")
                }
                loadingMeals = false
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
                    Event(meal_id: mealUUID, id: 1),
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
            selectedEvent: Event(meal_id: mealUUID, id: 1),
            meals: [
                Meal(id: mealUUID, name: "Test", description: "Test")
            ],
            preview: true
        )
    }
}
