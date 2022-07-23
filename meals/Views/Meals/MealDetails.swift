//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showLogMeal: Bool = false
    @State var showMealEditor: Bool = false
    @State var meal: Meal
    @State var mealEvents: [Event] = []
    @State var hours: Int = 3
    
    @State var newMealEventDate:Date = Date()
    
    @State var eventGlucoseSamples: [Int: (Date,[MetricSample])] = [:]
    @State var eventInsulinSamples: [Int: (Date,[MetricSample])] = [:]
    @State var mealEventsRange: (Date,Date)?
    
    
    func drawGlucoseAggs() -> some View {
        // Calculate ranges and step sizes
        HStack {
            ValueStats(eventSamples: eventGlucoseSamples,
                       hoursAhead: hours,
                       dateStepSizeMinutes: hours < 5 ? 30 : 60,
                       valueMin: 75 ,
                       valueStepSize: 25,
                       valueMax: 300,
                       valueColor: { value in
                if value < 70 {
                    return .black
                } else if value  <  180 {
                    return  .green
                } else if value < 250 {
                    return  .red
                } else {
                    return  .black
                }
            }
            )
            .frame(height: 160)
        }
    }
    
    func drawInsulinAggs() -> some View {
        // Calculate ranges and step sizes
        HStack {
            ValueStats(eventSamples: eventInsulinSamples,
                       hoursAhead: hours,
                       valueAxisEvery: 2,
                       dateStepSizeMinutes: hours < 5 ? 30 : 60,
                       valueMin: 0 ,
                       valueStepSize: 0.5,
                       valueMax: 3,
                       valueColor: { _ in Color.accentColor }
            )
                .frame(height: 160)
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { geo in
                    ScrollView {
                        MealCard(meal: meal)
                            .frame(width: geo.size.width, height: geo.size.height/2)
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("Description")
                                    .font(.headline)
                                    .padding(.bottom)
                                Text(meal.description)
                            }
                            .padding()
                            .frame(width: geo.size.width, alignment: .leading)
                            .background(Color(uiColor: UIColor.systemBackground))
                            .cornerRadius(15)
                            
                            
                            VStack(alignment: .leading) {
                                HStack() {
                                    Text("Glucose statistics")
                                        .font(.headline)
                                    Text("total: \(mealEvents.count)")
                                        .font(.subheadline)
                                }
                                if eventGlucoseSamples.count == mealEvents.count {
                                    drawGlucoseAggs()
                                        .padding()
                                } else if mealEvents.count > 0 {
                                    Text("Loading..")
                                    ProgressView()
                                } else {
                                    Text("No events")
                                }
                                
                                HStack() {
                                    Text("Insulin statistics")
                                        .font(.headline)
                                    Text("total: \(mealEvents.count)")
                                        .font(.subheadline)
                                }
                                if eventInsulinSamples.count == mealEvents.count {
                                    drawInsulinAggs()
                                        .padding()
                                } else if mealEvents.count > 0 {
                                    ProgressView()
                                } else {
                                    Text("No events")
                                }
                                

                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color(uiColor: UIColor.systemBackground))
                            .cornerRadius(15)
                            
                            VStack {
                                List(mealEvents, id: \.id) { mealEvent in
                                    NavigationLink(
                                        destination: {
                                            MetricView(meal: meal, event: mealEvent)
                                                .onDisappear {
                                                    loadEvents()
                                                }
                                        },
                                        label: {
                                            Text(mealEvent.date.formatted())
                                        }
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color(uiColor: UIColor.systemBackground))
                            .cornerRadius(15)
                        }
                    }
                }
                HStack(alignment: .lastTextBaseline) {
                    Button(action: {showLogMeal.toggle() }) {
                        Image(systemName: "plus")
                            .frame(width: 50, height: 50)
                            .background(Color( red: 27, green: 27, blue: 27))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.2))
        .toolbar {
            Button("Edit"){
               showMealEditor = true
            }
        }
        .sheet(isPresented: $showMealEditor ){
            MealEditor(meal: meal, onCompletion: {
                showMealEditor = false
                presentationMode.wrappedValue.dismiss()
            })
        }
        .alert(isPresented: $showLogMeal) {
            let date = Date()
            return Alert(title: Text("Enter meal event at: \(date.formatted())"),
                         primaryButton: .default(Text("Yes")){
                EventsAPI.createEvent(event: Event(meal_id: meal.id, id: 0, date: date)) { result in
                    switch result {
                    case .success(_):
                        print("Success")
                        loadEvents()
                    case .failure(let error):
                        print("Error creating meal event: \(error)")
                    }
                }
            },
                         secondaryButton: .cancel()
            )
        }
        .onAppear {
            if mealEvents.isEmpty {
                loadEvents()
            }
        }
        
    }
    
    func loadEvents() {
        EventsAPI.getEvents(mealID: meal.id) { result in
            switch result {
            case .success(let events):
                mealEvents = events
                if !mealEvents.isEmpty{
                    let dates = events.map { $0.date}
                    mealEventsRange = (dates.min()!, dates.max()!)
                }
                eventGlucoseSamples = [:]
                eventInsulinSamples = [:]
                print("Loaded \(mealEvents.count) events")
                // TODO: Overlaps?
                mealEvents.forEach{ event in
                    Nightscout().getGlucoseSamples(event: event, hours: TimeInterval(hours*60*60)) { result in
                        switch result {
                            case .success(let samples):
                                eventGlucoseSamples[event.id] = (event.date, samples)
                            case .failure(let error):
                                print("Error \(error)")
                        }
                    }
                    HealthKitUtils().getInsulinSamples(
                        start: event.date,
                        end: event.date.advanced(by: TimeInterval(hours*60*60))
                    ) { result in
                        switch result {
                             case .success(let samples):
                                eventInsulinSamples[event.id] = (event.date, samples)
                            case .failure(let error):
                                print("Error \(error)")
                        }
                    }
                }
                
            case .failure(let error):
                print("Failed saving events: \(error)")
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
