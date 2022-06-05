//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    @Environment(\.presentationMode) var presentationMode
    
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
                    .cornerRadius(15)
                    
                    
                    VStack(alignment: .leading) {
                        HStack() {
                            Text("Meal events")
                                .font(.headline)
                            Text("total: \(mealEvents.count)")
                                .font(.subheadline)
                        }

                        
                        ForEach(mealEvents, id: \.id) { mealEvent in
                            NavigationLink(
                                destination: {
                                    MetricView(meal: meal, event: mealEvent)
                                },
                                label: {
                                    MetricView(event: mealEvent)
                                        .frame(height: 200)
                                }
                            )
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
                    EventsAPI.saveEvent(event: Event(meal_id: meal.id, date: Date()))
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
                    MealEditor(meal: meal)
                        .onDisappear {
                            presentationMode.wrappedValue.dismiss()
                        }
                },
                label: {
                   Text("Edit")
                }
            )
        }
        .onAppear {
            if mealEvents.isEmpty {
                EventsAPI.getEvents { result in
                    print("Appeared")
                    switch result {
                    case .success(let events):
                        mealEvents = events.filter { $0.meal_id == meal.id }
                        print("Loaded \(mealEvents.count) events")
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
        let mealID = 1
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
