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
    
    @Environment(\.presentationMode) var presentationMode
    @State var meal: Meal
    var image: UIImage?
    
    @State var showLogMeal: Bool = false
    @State var hours: Int = 3
    let hourOptions = [3, 6]
    
    @State var glucoseSamples: [Int: (Date, [MetricSample])] = [:]
    @State var insulinSamples: [Int: (Date, [MetricSample])] = [:]
    
    @State var glucosePointCount = 0
    @State var insulinPointCount = 0
    

    
    var body: some View {
        let mealEvents = eventStore.getEvents(mealId: meal.id)
        return NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    header
                    description
                    metrics(events: mealEvents)
                }
                .navigationBarTitle(Text("Meal details"), displayMode: .inline)
            }
            .background(.gray.opacity(0.2))
            .overlay {
                eventsActionButton
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Edit") {
                        MealEditor(
                            meal: meal,
                            image: image,
                            onEdit: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        .environmentObject(mealStore)
                    }
                }
            }
            .bottomSheet(isPresented: $showLogMeal, detents: [.medium()]) {
                MealEventLogger(meal: meal)
                    .environmentObject(eventStore)
            }
            .onAppear {
                loadSamples(events: mealEvents, hours: hours)
            }
            .onChange(of: hours) { newHours in
                loadSamples(events: mealEvents, hours: newHours)
            }
        }
        
    }
    
    var eventsActionButton: some View {
        GeometryReader { _ in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showLogMeal.toggle() }) {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                            Text("Event")
                                .foregroundColor(.white)
                        }
                        .padding(15)
                        .background(.primary)
                        .cornerRadius(15)
                    }
                    .shadow(radius: 5)
                    .padding()
                }
            }
        }
    }
    
    var header: some View {
        // Todo: Maybe this should be it's own component "MealHeader" ?
        let colors = [Color(hex: 0x424242), Color(hex: 0x002266)]
        return GeometryReader { geo in
            // Photo
            ZStack {
                VStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height:200, alignment: .center)
                            .clipped()
                    } else {
                        ZStack {
                            LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 70, height: 50)
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(.white)
                        }
                    }
                }
                // Titles
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack {
                        Text(meal.name)
                            .font(.largeTitle)
                            .minimumScaleFactor(0.001)
                        Spacer()
                    }
                }
                .padding([.leading, .trailing,.bottom], 5)
                .foregroundColor(.white)
                .background(
                    .linearGradient(
                        colors: [.black, .black.opacity(0)],
                        startPoint: .bottom,
                        endPoint: .top)
                )
            }
        }
        .frame(height: 200)
        
    }
    
    var description: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Description")
                    .font(.headline)
                    .padding(.bottom)
                Text(meal.description)
            }
            Spacer()
        }
        .padding()
        .background(Color(uiColor: UIColor.systemBackground))
        .cornerRadius(15)
        .padding([.leading, .trailing], 5)
    }
    
    var glucoseStatistics: some View {
        // Calculate ranges and step sizes
        let resolution = TimeInterval(15 * 60)
        let range = TimeInterval(hours * 60 * 60)
        let samples = glucoseSamples.map {
            $0.value
        }
        return GlucoseStatisticsChart(range: range, resolution: resolution, samples: samples)
    }
    
    var insulinStatistics: some View {
        let resolution = TimeInterval(15 * 60)
        let range = TimeInterval(hours * 60 * 60)
        let samples = insulinSamples.map {
            ($0.value.0, calculateIOB(
                insulinDelivery: $0.value.1,
                start: $0.value.0,
                end: $0.value.0.addingTimeInterval(range)
            ))
        }
        return InsulinStatisticsChart(range: range, resolution: resolution, samples: samples)
    }
    
    var hoursPicker: some View {
        Picker("", selection: $hours) {
            ForEach(hourOptions, id: \.self) { hour in
                Text("\(hour) hours")
            }
        }
        .pickerStyle(.menu)
    }
    
    func metrics(events: [Event]) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Metrics")
                    .font(.headline)
                Spacer()
                Text("total events: \(events.count)")
                    .font(.subheadline)
                Spacer()
                hoursPicker
            }
                .padding([.leading, .top, .trailing], 10)
            
            if events.count > 0 {
                Divider()
                Text("Statistics")
                    .font(.subheadline)
                    .padding([.leading, .top, .trailing], 10)
                if insulinPointCount + glucosePointCount == 0 {
                    NoDataView(
                        title: "No health data"
                    )
                } else {
                    glucoseStatistics.frame(height: 200)
                    insulinStatistics.frame(height: 200)
                }
                
                
                eventsList(events: events)
            } else {
                NoDataView(
                    title: "No events",
                    prompt: "Create an event"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(uiColor: UIColor.systemBackground))
        .cornerRadius(15)
        .padding([.leading, .trailing], 5)

    }
    
    func eventsList(events: [Event]) -> some View {
        VStack(alignment: .leading) {
            let metricStore = Store.createMetricStore()
            Text("Meal events")
                .padding([.leading, .top, .trailing], 10)
            Divider()
            ForEach(events, id: \.id) { event in
                NavigationLink(destination: {
                    EventView(
                        metricStore: metricStore,
                        meal: meal,
                        event: event,
                        image: image
                    )
                    .environmentObject(eventStore)
                }) {
                    HStack {
                        Text(DateUtils.formatDateAndTime(date: event.date))
                        Spacer()
                        Image(systemName: "arrow.forward.circle")
                    }
                    .padding()
                }
                MetricGraph(
                    metricStore: metricStore,
                    hideTitle: true,
                    event: event,
                    dataType: .Glucose,
                    hours: hours
                )
                    .frame(height: 100)
                Divider()
                    .frame(maxHeight: 15)
                    .background(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(5)
        .background(Color(uiColor: UIColor.systemBackground))
        .cornerRadius(15)
    }
    
    func loadSamples(events: [Event], hours: Int) {
        let metricStore = Store.createMetricStore()
        glucosePointCount = 0
        glucoseSamples = [:]
        
        insulinSamples = [:]
        insulinPointCount = 0
        // TODO: Overlaps?
        events.forEach { event in
            let start = event.date
            let end = event.date.advanced(by: TimeInterval(hours * 60 * 60))
            metricStore.getGlucoseSamples(start: start, end: end) { result in
                switch result {
                case .success(let samples):
                    glucoseSamples[event.id] = (event.date, samples)
                    glucosePointCount+=samples.count
                case .failure(let error):
                    print("Error \(error)")
                }
                
            }
            metricStore.getInsulinSamples(
                start: start,
                end: end
            ) { result in
                switch result {
                case .success(let samples):
                    insulinSamples[event.id] = (event.date, samples)
                    insulinPointCount += samples.count
                case .failure(let error):
                    print("Error \(error)")
                }
            }
        }
    }
    
}

struct MealEventLogger: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var eventStore: EventStore
    @State var date: Date = Date.now
    var meal: Meal
    
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Log an event")
                .font(.largeTitle)
            HStack {
                Text("Log an event for")
                Text(meal.name)
                    .fontWeight(.heavy)
            }
            .font(.subheadline)
            DatePicker("Event date", selection: $date, displayedComponents: [.date])
            DatePicker("Event time", selection: $date, displayedComponents: [.hourAndMinute])
            Spacer()
            HStack {
                Button("Save") {
                    let event = Event(meal_id: meal.id, id: 0, date: date)
                    do {
                        try eventStore.saveEvent(event: event)
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        showErrorAlert = true
                        errorMessage = "Failed saving event: \(error)"
                    }
                    
                }
                .padding()
                Spacer()
                Button("Cancel", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        }
    }
    
}

struct MealDetails_Previews: PreviewProvider {
    static var previews: some View {
        let exampleMeal: Meal = Meal(
            id: 1,
            name: "Example meal",
            description: "Description"
        )
        let mealID = 1
        let storeWithData = Store(
            meals: [exampleMeal],
            events: [
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID),
                Event(meal_id: mealID)
            ]
        )
        let storeWitouthData = Store(
            meals: [exampleMeal],
            events: []
        )
        Group {
            MealDetails(
                meal: exampleMeal
            )
            .environmentObject(storeWithData.mealStore)
            .environmentObject(storeWithData.eventStore)
            
            MealDetails(
                meal: exampleMeal
            )
            .environmentObject(storeWitouthData.mealStore)
            .environmentObject(storeWitouthData.eventStore)

        }
    }
}
