//
//  EventList.swift
//  meals
//
//  Created by aclowkey on 01/06/2022.
//

import Foundation

import SwiftUI

struct EventList: View {
    var metricStore: MetricStore
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

    var body: some View {
        VStack {
            if let selectedEvent = selectedEvent {
                header
                statistics(event: selectedEvent)
                timeline
            } else {
                EventListSkeleton()
            }
        }
                .background(.gray.opacity(0.2))
                .onAppear {
                    withAnimation {
                        ready = true
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
                ZStack {
                    // Photo
                    HStack {
                        if let image = image {
                            Image(uiImage: image).resizable().scaledToFill()
                        } else {
                            LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                        }
                    }
                            .frame(height: 120)
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Text(meal.name)
                                    .font(.largeTitle)
                            Spacer()
                        }
                        HStack {
                            Text("\(DateUtils.dateAndTimeFormat(date: selectedEvent.date))")
                            Spacer()
                        }
                        Spacer()
                    }
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                    .linearGradient(
                                            colors: [.black, .black.opacity(0)],
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
                .frame(height: 100)
    }

    func statistics(event: Event) -> some View {
        VStack {
            HStack {
                Text("Statistics")
                        .font(.headline)
                        .padding([.leading, .top], 10)
                Spacer()
            }
            VStack {
                Text("Glucose")
                MetricGraph(metricStore: metricStore, event: event, dataType: .Glucose, hours: hours)
            }
            VStack {
                Text("Insulin")
                MetricGraph(metricStore: metricStore, event: event, dataType: .Insulin, hours: hours)
            }
            Spacer()
        }
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(15)
                .padding([.leading, .trailing, .bottom], 5)
    }

    var timeline: some View {
        let timelineEvents = getTimelineEvents()
        return VStack {
            HStack {
                Text("Timeline")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .padding(.top, 5)
                        .padding(.leading, 10)
                Spacer()
            }
                    .frame(height: 30)
                    .padding(.trailing, 10)

            HStack {
                if eventStore.events.isEmpty {
                    noData
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(timelineEvents.enumerated()), id: \.1.hashValue) { index, timelineEvent in
                                timelineCard(
                                        meal: mealStore.getMeal(event: timelineEvent.event)!,
                                        event: timelineEvent.event,
                                        firstInDay:
                                        index == 0 || !isSameDay(
                                                date1: timelineEvents[index - 1].event.date,
                                                date2: timelineEvent.event.date
                                        )
                                )
                                        .onTapGesture {
                                            withAnimation {
                                                selectedEvent = timelineEvent.event
                                            }
                                        }
                            }
                        }
                    }
                }
            }
                    .padding(.bottom, 10)
        }
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(15)
                .padding([.leading, .trailing], 5)
    }

    func timelineCard(meal: Meal, event: Event, firstInDay: Bool) -> some View {
        VStack {
            HStack {
                if firstInDay {
                    Text(DateUtils.formatDateWithRelativeDay(date: event.date))
                }
                Spacer()
            }
            HStack {
                Text(DateUtils.formatTime(date: event.date))
                        .font(.caption)
                        .padding(0)
                Spacer()
            }
            MealCard(
                    font: .caption,
                    meal: meal,
                    image: try? photoStore.loadImage(mealID: meal.id)
            )
                    .clipShape(
                            RoundedRectangle(
                                    cornerSize: CGSize(width: 10, height: 10)))
                    .frame(width: 100, height: 100)
        }
                .padding(.leading, 10)
    }

    var noData: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center) {
                Image(systemName: "tray.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary.opacity(0.5))
                        .font(.system(size: 30, weight: .ultraLight))
                        .frame(width: 80)

                Text("No data")
                        .font(.title)

                HStack(alignment: .center) {
                    Spacer()
                    Text("Log an event")
                            .font(.body)
                    Spacer()
                }
            }
            Spacer()
        }

    }

    // Event handler
    func onMealTap(meal: Meal) {
        showLogEventAlert = true
        mealToLog = meal
    }

    // Helpers
    func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }

    func getTimelineEvents() -> [TimelineEvent] {
        eventStore.events.compactMap {
            // This really shouldn't happen...
            // right now it happens because of bad deletion of meals but not related events
            guard let meal = mealStore.getMeal(event: $0) else {
                return nil
            }
            return TimelineEvent(
                    event: $0,
                    mealUpdatedAt: meal.updatedAt
            )
        }
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
                ],
                settings: Settings(dataSourceType: .Debug)
        )
        EventList(metricStore: store.metricStore)
                .environmentObject(store.mealStore)
                .environmentObject(store.eventStore)
                .environmentObject(store.photoStore)
    }
}
