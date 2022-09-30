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
        let loadedEvents: [Event] = JsonUtils
                .load(fileName: EventStore.fileName) ?? []
        events = loadedEvents.sorted(by: { $0.date > $1.date })
    }

    init(mealStore: MealStore, events: [Event]) {
        self.mealStore = mealStore
        self.events = events
    }

    func saveEvent(event: Event) {
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
        JsonUtils.save(data: events, fileName: EventStore.fileName)
        mealStore.updateMealUpdateDate(event: event)
    }

    func deleteEvent(eventId: Int) {
        events = events.filter {
            $0.id != eventId
        }
        JsonUtils.save(data: events, fileName: EventStore.fileName)
    }

    func getEvents(mealId: Int) -> [Event] {
        events.filter {
            $0.meal_id == mealId
        }
    }
}
