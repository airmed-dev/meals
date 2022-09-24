//
//  EventList.swift
//  meals
//
//  Created by aclowkey on 01/06/2022.
//

import Foundation

import SwiftUI

struct EventList: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
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
            Spacer()
            if let selectedEvent = selectedEvent {
                header
                statistics(event: selectedEvent, title: "Glucose", type: .Glucose)
                statistics(event: selectedEvent, title: "Insulin", type: .Insulin)
                timeline
            } else {
                EventListSkeleton()
            }
            Spacer()
        }
                .background(.gray.opacity(0.2))
                .onAppear {
                    withAnimation {
                        ready = true
                        selectedEvent = viewModel.events.first
                    }
                }
    }
    var header: some View {
        let colors = [Color(hex: 0x424242), Color(hex: 0x002266)]
        let meal = selectedEvent != nil
                ? viewModel.getMeal(event: selectedEvent!)!
                : nil
        let image = meal != nil
                ? viewModel.loadImage(meal: meal!)
                : nil

        return HStack {
            if let selectedEvent = selectedEvent {
                // Photo
                HStack {
                    if let image = image {
                        Image(uiImage: image).resizable()
                    } else {
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                    }
                }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.leading, 5)

                // Texts
                VStack {
                    Spacer()
                    HStack {
                        Text(meal!.name)
                                .font(.headline)
                        Spacer()
                    }
                    HStack {
                        Text("\(formatDate(date: selectedEvent.date)) at \(formatTime(date: selectedEvent.date))")
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            } else {
                VStack {
                    Spacer()
                    Circle()
                            .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                            .frame(width: 100, height: 100)
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Text("No event is selected")
                                .font(.headline)
                                .frame(height: 30)
                    }
                    HStack {
                        Text("Select an event in the timeline")
                                .font(.caption)
                                .frame(height: 10)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
                .background(.white)
                .cornerRadius(15)
                .frame(height: 130)
    }

    func statistics(event: Event, title: String, type: DataType) -> some View {
        VStack {
            HStack {
                Text(title)
                        .font(.headline)
                        .padding([.leading, .top], 10)
                Spacer()
            }
            MetricGraph(event: event, dataType: type, hours: hours)
        }
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(15)
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
                if viewModel.events.isEmpty {
                    noData
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(timelineEvents.enumerated()), id: \.1.hashValue) { index, timelineEvent in
                                timelineCard(
                                        meal: viewModel.getMeal(event: timelineEvent.event)!,
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
                    .frame(height: 150)

        }
                .background(Color(uiColor: .systemBackground))
                .padding(.top, 5)
                .padding(.bottom, 15)
                .padding(.leading, 3)
                .padding(.trailing, 3)
                .cornerRadius(15)
    }

    func timelineCard(meal: Meal, event: Event, firstInDay: Bool) -> some View {
        VStack {
            HStack {
                if firstInDay {
                    Text(formatDate(date: event.date))
                }
                Spacer()
            }
            Spacer()
            HStack {
                Text(formatTime(date: event.date))
                        .font(.caption)
                        .padding(0)
                Spacer()
            }
            MealCard(
                    font: .caption,
                    meal: meal,
                    image: viewModel.loadImage(meal: meal)
            )
                    .clipShape(
                            RoundedRectangle(
                                    cornerSize: CGSize(width: 10, height: 10)))
                    .frame(width: 100, height: 100)
        }
                .padding(.leading, 10)
                .padding(.bottom, 5)
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
        return Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }

    func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func formatDate(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }

    func getTimelineEvents() -> [TimelineEvent] {
        viewModel.events.map {
            TimelineEvent(
                    event: $0,
                    mealUpdatedAt: viewModel.getMeal(event: $0)!.updatedAt
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
        let mealUUID = 1
        EventList()
                .environmentObject(ContentViewViewModel(
                        meals: [
                            Meal(id: mealUUID, name: "Test", description: "Test")
                        ],
                        events: [
                            Event(meal_id: mealUUID, id: 1),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                            Event(meal_id: mealUUID),
                        ]
                ))
    }
}
