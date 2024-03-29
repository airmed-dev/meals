//
// Created by aclowkey on 25/09/2022.
//

import Foundation

class EventStore: ObservableObject {
    @Published var events: [Event]

    private static let fileName = "events.json"
    private var mealStore: MealStore

    init(mealStore: MealStore) {
        self.mealStore = mealStore
        self.events = []
    }

    init(mealStore: MealStore, events: [Event]) {
        self.mealStore = mealStore
        self.events = events
    }
    
    func load() throws {
        let url = try FileManager.default.url(
                 for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: false
        ).appendingPathComponent(EventStore.fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            events = try JsonUtils.load(fileName: EventStore.fileName) ?? []
        } else {
            try JsonUtils.save(data: events,  fileName:EventStore.fileName)
        }
        
        events = events.sorted(by: { $0.date > $1.date })
    }

    func saveEvent(event: Event) throws {
        if (event.id == 0) {
            let largestEventID = events.map {
                        $0.id
                    }
                    .max()
            let newEventID = (largestEventID ?? 0) + 1
            let newEvent = Event(
                    meal_id: event.meal_id,
                    id: newEventID,
                    date: event.date
            )
            events.insert(newEvent, at: 0)
        } else {
            let eventIndex = events.firstIndex(where: { $0.id == event.id })
            guard let eventIndex = eventIndex else {
                return
            }
            events[eventIndex] = event
        }
        try JsonUtils.save(data: events, fileName: EventStore.fileName)
        try mealStore.updateMealUpdateDate(event: event)
    }

    func deleteEvent(eventId: Int) throws {
        events = events.filter {
            $0.id != eventId
        }
        try JsonUtils.save(data: events, fileName: EventStore.fileName)
    }

    func getEvents(mealId: Int) -> [Event] {
        events.filter {
            $0.meal_id == mealId
        }
    }
}
