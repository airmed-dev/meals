//
//  TimelineView.swift
//  meals
//
//  Created by aclowkey on 16/10/2022.
//

import SwiftUI
import SwiftUITrackableScrollView

struct TimelineView: View {
    @EnvironmentObject var mealStore: MealStore
    @EnvironmentObject var photoStore: PhotoStore
    @Binding var selectedEvent: Event?
    private let cardWidth: CGFloat
    private let spacing:CGFloat = 5
    var events: [Event]
    
    init(cardWidth: CGFloat, events: [Event], selectedEvent: Binding<Event?>){
        self.cardWidth = cardWidth
        self.events = events
            .sorted(by: { $0.date > $1.date})
        self._selectedEvent = selectedEvent
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: spacing) {
                ForEach(eventGroupDateKeys(), id: \.self){ groupDateKey in
                    cardGroup(groupDateKey:  groupDateKey)
                }
            }
        }
    }

    func cardGroup(groupDateKey: String) -> some View {
        VStack() {
            HStack(spacing: spacing) {
                let events = eventsPerDates(groupDateKey: groupDateKey)
                ForEach(events){ event in
                    timelineCard(event: event,
                                firstInGroup: events.first!.id == event.id)
                }
            }
        }
    }
    
    func timelineCard(event: Event, firstInGroup: Bool) -> some View {
        VStack {
            VStack {
                if firstInGroup {
                    HStack {
                        Text(DateUtils.formatDayMonth(date: event.date))
                        Spacer()
                    }
                }
                Spacer()
                HStack {
                    Text(DateUtils.formatTime(date: event.date))
                    Spacer()
                }
            }
            .frame(height: 50)
            .padding([.leading, .top], 5)
            
            if let meal = mealStore.getMeal(event: event){
               mealCard(meal: meal, event: event)
            } else {
                Text("ERROR: No meal for event \(event.id)")
            }
        }
        .frame(width: cardWidth)
    }
    
    func mealCard(meal: Meal, event: Event) -> some View {
        VStack() {
            if selectedEvent?.id == event.id{
                MealCard(
                    title: meal.name,
                    titleFont: .caption,
                    image: try? photoStore.loadImage(mealID: meal.id)
                )
                .cornerRadius(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 3)
                }
            } else {
                MealCard(
                    title: meal.name,
                    titleFont: .caption,
                    image: try? photoStore.loadImage(mealID: meal.id)
                )
                .cornerRadius(10)
            }
        }
        .onTapGesture {
            selectedEvent = event
        }
    }
    
    func eventGroupDateKeys() -> [String] {
        var deduplicated: [String] = []
        events
            .map { $0.date }
            .map { DateUtils.formatDayMonth(date: $0)}
            .forEach {
                if deduplicated.firstIndex(of: $0) == nil {
                    deduplicated.append($0)
                }
            }
        return deduplicated
    }
    
    func eventsPerDates(groupDateKey: String) -> [Event] {
        return events
            .filter { groupDateKey == DateUtils.formatDayMonth(date: $0.date) }
            .sorted(by: {$0.date > $1.date})
    }
    
}

struct TimelineView_Previews: PreviewProvider {
    static let store = Store(
        meals: [Meal(id: 0, name: "Dummy meal", description: "")],
        events: []
    )
    static let events = [
        // Day 0
        Event(meal_id: 0,id:0, date: Date.now.addingTimeInterval(24*60*60*(-5))),
        Event(meal_id: 0,id:1, date: Date.now.addingTimeInterval(24*60*60*(-5.1))),
        
        // Day 1
        Event(meal_id: 0,id:2, date: Date.now.addingTimeInterval(24*60*60*(-4.1))),
        Event(meal_id: 0,id:3, date: Date.now.addingTimeInterval(24*60*60*(-4.2))),
        Event(meal_id: 0,id:4, date: Date.now.addingTimeInterval(24*60*60*(-4.3))),
        
        // Day 2
        Event(meal_id: 0,id:5, date: Date.now.addingTimeInterval(24*60*60*(-3))),
        //
        // Day 3
        Event(meal_id: 0,id:6, date: Date.now.addingTimeInterval(24*60*60*(-2.1))),
        Event(meal_id: 0,id:7, date: Date.now.addingTimeInterval(24*60*60*(-2.3))),
        //
        // Day 4
        Event(meal_id: 0,id:8, date: Date.now.addingTimeInterval(24*60*60*(-1.5))),
    ]
    @State static var selectedEvent: Event?
    static var previews: some View {
        VStack {
            if let selectedEvent = selectedEvent {
                Text("Selected Event: \(selectedEvent.date)")
            }
            TimelineView(
                cardWidth: 120,
                events: events,
                selectedEvent: $selectedEvent
            )
            .frame(height: 200)
            .environmentObject(
                store.mealStore
            )
            .environmentObject(
                store.photoStore
            )
        }
        .onAppear  {
            selectedEvent = events.first
        }
    }
}
