//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var mealStore: MealStore
    
    @State var meal: Meal
    
    var body: some View {
        VStack {
            List{
            Section {
                Text(meal.name)
                    .font(.headline)
                Text(meal.description)
                Spacer().listSectionSeparator(.hidden)
            }
            Section(header: Text("Meal events")) {
                ForEach(eventStore.events, id: \.id) { mealEvent in
                        ScrollView {
                            HStack {
                                NavigationLink(destination: {
                                    MetricView(
                                        event: mealEvent
                                    )
                                },
                                   label: {
                                    VStack {
                                        MetricGraph(samplePoints: [
                                                MetricSample(Date.init(timeIntervalSinceNow: 480), 70),
                                                MetricSample(Date.init(timeIntervalSinceNow: 120), 175),
                                                MetricSample(Date.init(timeIntervalSinceNow: 60), 160),
                                                MetricSample(Date.init(timeIntervalSinceNow: 0), 190),
                                            ],
                                            start: Date.init(timeIntervalSinceNow: 1000),
                                            end:Date.now,
                                            width: 1
                                        )
                                        .frame(width: 100, height:100)
                                        Text(mealEvent.date.formatted(.iso8601))
                                    }
                                })
                            }
                        }
                    }
                }
            }

            HStack {
                Button("Log Entry") {
                    var newEvents = eventStore.events
                    newEvents.append(Event(meal_id: meal.id))
                    eventStore.save(events: newEvents) { result in
                        switch result {
                        case .success(let count):
                            print("Saved \(count) events")
                            eventStore.events = newEvents
                        case .failure(let error):
                            print("Failed saving events: \(error)")
                        }
                    }
                }
            }
        }
        .toolbar {
            NavigationLink(
                destination: {
                    MealEditor(meal: meal, onSave: { meal in
                        var newMeals = mealStore.meals
                        let mealIndex = newMeals.firstIndex(where: { $0.id == meal.id })!
                        newMeals[mealIndex] = meal
                        
                        mealStore.save(meals: newMeals, completion: { result in
                            switch result {
                            case .success(let count):
                                print("Saved \(count) meals")
                                
                                mealStore.meals = newMeals
                            case .failure(let error):
                                print("Failed saving meals: \(error)")
                            }
                        })
                        
                    })
                },
                label: {
                   Text("Edit")
                }
            )
        }
        .onAppear {
            eventStore.load { result in
                print("Appeared")
                switch result {
                case .success(let events):
                    eventStore.events = events.filter { $0.meal_id == meal.id }
                    print("Loaded \(eventStore.events.count) events")
                case .failure(let error):
                    print("Failed saving events: \(error)")
                }
                
            }
        }
        
    }
}

struct MealDetails_Previews: PreviewProvider {
    static var previews: some View {
        MealDetails(meal: Meal(id: UUID(),
                   name: "Pitaya Smoothie Bowl",
                   description: "Add the frozen pitaya, banana, strawberries and coconut water into a high powered blender. Blend on high for one minute, until well combined. jour your pitaya smoothie into a bowl and add your toppings."
                  )
        ).environmentObject(EventStore())
    }
}
