//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    @State var meal: Meal
    @State var events: [Event] = []
    
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
                    ForEach(events, id: \.id) { mealEvent in
                        ScrollView {
                            HStack {
                                NavigationLink(destination: {
                                    MetricView(
                                        event: Event(id: UUID(), date: Date.now)
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
                    print("Logged entry")
                    events.append(Event())
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
                              ),
                    events: [Event(), Event()]
        )
    }
}
