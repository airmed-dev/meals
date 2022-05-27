//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    var eventStore: EventStore = EventStore()
    var mealStore: MealStore = MealStore()
    
    @State var meal: Meal
    @State var mealEvents: [Event] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading) {
                    MealCard(meal: meal)
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.headline)
                            .padding(.bottom)
                        Text(meal.description)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(.white)
                    .cornerRadius(15)
                    
                    
                    VStack(alignment: .leading) {
                        HStack() {
                            Text("Meal events")
                                .font(.headline)
                            Text("total: \(mealEvents.count)")
                                .font(.subheadline)
                                .foregroundColor(Color.black.opacity(0.95))
                        }

                        
                        ForEach(mealEvents, id: \.id) { mealEvent in
                            NavigationLink(
                                destination: {
                                    MetricView(event: mealEvent)
                                },
                                label: {
                                    MetricView(event: mealEvent)
                                        .frame(height: 200)
                                }
                            )
                            .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(.white)
                    .cornerRadius(15)
                }
            }
            HStack(alignment: .lastTextBaseline) {
                Button("Log Entry") {
                    var newEvents = eventStore.events
                    newEvents.append(Event(meal_id: meal.id))
                    eventStore.save(events: newEvents) { result in
                        switch result {
                        case .success(let count):
                            print("Saved \(count) events")
                            mealEvents = newEvents
                        case .failure(let error):
                            print("Failed saving events: \(error)")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(.white)
        }
        .padding()
        .background(.gray.opacity(0.2))
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
            if mealEvents.isEmpty {
                eventStore.load { result in
                    print("Appeared")
                    switch result {
                    case .success(let events):
                        mealEvents = events.filter { $0.meal_id == meal.id }
                        print("Loaded \(eventStore.events.count) events")
                    case .failure(let error):
                        print("Failed saving events: \(error)")
                    }
                    
                }
            }
        }
        
    }
}

struct MealDetails_Previews: PreviewProvider {
    static var previews: some View {
        let mealID = UUID()
        MealDetails(
            meal: MealStore.exampleMeal,
            mealEvents: [
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID)
            ]
        )
    }
}
