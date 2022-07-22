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
    @State var meals: [Int: Meal] = [:]
    
    @State var preview = false
    
    @State var loadingEvents = true
    @State var loadingMeals = true
    @State var hours = 3
    @State var selectedMealPhoto: UIImage?
    
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
                        if let se = selectedEvent {
                            HStack {
                                if let sm = selectedMealPhoto {
                                    Image(uiImage: sm)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 60)
                                        .clipShape(Circle())
                                }
                                Text(meals[se.meal_id]!.name)
                                    .font(.headline)
                            }
                            .padding()
                        }
                        Spacer()
                        HStack(alignment: .firstTextBaseline) {
                            Menu {
                                Button {
                                    hours = 3
                                } label: {
                                    Text("3 hours")
                                }
                                Button {
                                    hours = 6
                                } label: {
                                    Text("6 hours")
                                }
                            }
                            label: {
                                Text("\(hours) hours")
                            }
                        }
                        
                    }
                    
                    
                    GeometryReader{ geo in
                        VStack(alignment: .center){
                            if let se = selectedEvent {
                                MetricGraph(event: se, dataType: .Glucose, hours: hours)
                            } else {
                                HStack(alignment: .center) {
                                    Text("No event selected")
                                }
                                .frame(width: geo.size.width, height: geo.size.height)
                                .background(Color(.systemGroupedBackground))
                            }
                        }
                    }
                    
                    Spacer()
                    Text("Events")
                        .font(.headline)
                        .padding()
                    let eventDates = events.map { $0.key }.sorted(by: >)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(eventDates, id: \.self ){ key in
                                VStack(alignment: .leading) {
                                    Text(formatAsDay(key))
                                        .font(.subheadline)
                                    
                                    let currentEvents = events[key]!
                                    HStack {
                                        ForEach(currentEvents){ event in
                                            VStack(alignment: .leading) {
                                                if let meal = meals[event.meal_id]{
                                                    EventTimelineCard(meal: meal, event: event)
                                                        .onTapGesture {
                                                            selectedEvent = event
                                                            PhotosAPI.getPhoto(meal: meals[event.meal_id]!){ result in
                                                                switch result {
                                                                case .success(let photo):
                                                                    selectedMealPhoto = photo
                                                                    break
                                                                case .failure(let error):
                                                                    break
                                                                }
                                                            }
                                                        }
                                                } else {
                                                    Text("Error: No meal")
                                                }
                                            }
                                            .frame(width: 200, height: 200)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 200)
                    
                }
                .navigationTitle("Events")
            }
        }
        .onAppear {
            if preview {
                return
            }
            loadData()
        }
    }
    
    func formatAsDay(_ date:Date) -> String {
        if(Calendar.current.isDateInToday(date)){
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func loadData(){
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
                meals = Dictionary(grouping: loadedMeals, by: {$0.id} )
                    .mapValues { value in value.first! }
            case .failure(let error):
                print("Error fetching events:\(error)")
            }
            loadingMeals = false
        }
    }
    
    func formatAsTime(_ date:Date) -> String {
        let hourlyFormatter = DateFormatter()
        hourlyFormatter.dateFormat = "HH:mm"
        return hourlyFormatter.string(from: date)
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
                mealUUID: Meal(id: mealUUID, name: "Test", description: "Test")
            ],
            preview: true,
            loadingEvents: false,
            loadingMeals:  false
        )
    }
}
