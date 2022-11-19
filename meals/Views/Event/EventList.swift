//
//  EventList.swift
//  meals
//
//  Created by aclowkey on 01/06/2022.
//

import Foundation

import SwiftUI

struct EventList: View {
    @EnvironmentObject var mealStore: MealStore
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var photoStore: PhotoStore
    @State var ready = false
    
    // Meal event logging
    @State var showMealSelector = false
    @State var showLogEventAlert = false
    @State var mealToLog: Meal? = nil
    @State var mealEventDate: Date = Date()
    
    // Meal event logging alerts
    @State var showMealSuccessAlert = false
    
    // Event statistics
    @State var selectedEvent: Event? = nil
    @State var hours = 3
    let hourOptions = [3, 6]
    
    var body: some View {
        VStack {
            if eventStore.events.isEmpty {
                NoDataView(
                    title: "No events",
                    prompt: "Log an event"
                )
            } else if let selectedEvent = selectedEvent {
                header
                statistics(event: selectedEvent)
                timeline
            } else {
                EventListSkeleton()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            withAnimation {
                selectedEvent = eventStore.events.first
            }
        }
    }
    
    var header: some View {
        let colors = [Color(hex: 0x424242), Color(hex: 0x002266)]
        let meal = selectedEvent != nil
            ? mealStore.getMeal(event: selectedEvent!)
            : nil
        let image = meal != nil
            ? try? photoStore.loadImage(mealID: meal!.id)
            : nil
        
        return HStack {
            if let selectedEvent = selectedEvent, let meal = meal {
                // Todo: Maybe this should be it's own component "MealHeader" ?
                ZStack {
                    // Photo
                    GeometryReader{ geo in
                        HStack {
                            if let image = image {
                                Image(uiImage: image).resizable()
                            } else {
                                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                            }
                        }
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    }
                    
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Text(meal.name)
                                .font(.largeTitle)
                                .minimumScaleFactor(0.01)
                            Spacer()
                        }
                        HStack {
                            Text("\(DateUtils.formatDateAndTime(date: selectedEvent.date))")
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        .linearGradient(
                            stops:[
                                Gradient.Stop(color: .black, location: 0),
                                Gradient.Stop(color: .black.opacity(0), location: 0.9)
                            ],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                    .padding([.leading, .trailing], 5)
                }
                
            } else {
                ZStack {
                    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("No event is selected")
                                .font(.headline)
                                .frame(height: 30)
                            Text("Select an event in the timeline")
                                .font(.caption)
                                .frame(height: 10)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .frame(height: 150)
    }
    
    func statistics(event: Event) -> some View {
        let metricStore = Store.createMetricStore()
        return VStack {
            HStack {
                Text("Metrics")
                    .font(.headline)
                Spacer()
                Picker("Hours", selection: $hours) {
                    ForEach(hourOptions, id: \.self) { hour in
                        Text("\(hour) hours")
                    }
                }
            }
            .padding([.leading, .top, .trailing], 10)
            GlucoseInsulinGraph(
                metricStore: metricStore,
                event: event,
                hours: hours
            )
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(15)
        .padding([.leading, .trailing, .bottom], 5)
    }
    
    var timeline: some View {
        return VStack {
            HStack {
                Text("Timeline")
                    .font(.headline)
                Spacer()
            }
            .padding([.leading, .top, .trailing], 10)
            TimelineView(
                cardWidth: 130,
                events: eventStore.events,
                selectedEvent: $selectedEvent
            )
            .environmentObject(mealStore)
            .frame(height: 200)
            .background(.white)
            .cornerRadius(5)
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(15)
        .padding([.leading, .trailing], 5)
    }
    
    // Event handler
    func onMealTap(meal: Meal) {
        showLogEventAlert = true
        mealToLog = meal
    }
    
}

struct TimelineEvent: Hashable {
    var event: Event
    var mealUpdatedAt: Date
}

struct EventList_Previews: PreviewProvider {
    
    static var previews: some View {
        let mealID = 1
        let store = Store(
            meals: [
                Meal(id: mealID, name: "Test", description: "Test")
            ],
            events: [
                Event(meal_id: mealID, id: 1),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
            ]
        )
        EventList()
            .environmentObject(store.mealStore)
            .environmentObject(store.eventStore)
            .environmentObject(store.photoStore)
        
        let emptyStore = Store(
            meals: [
                Meal(id: mealID, name: "Test", description: "Test")
            ],
            events: [
            ]
        )
        EventList()
            .environmentObject(emptyStore.mealStore)
            .environmentObject(emptyStore.eventStore)
            .environmentObject(emptyStore.photoStore)
        
    }
}
