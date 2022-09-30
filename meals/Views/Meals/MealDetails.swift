//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    var metricStore: MetricStore
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var mealStore: MealStore

    @Environment(\.presentationMode) var presentationMode
    @State var meal: Meal
    var image: UIImage?
    
    @State var showLogMeal: Bool = false
    @State var hours: Int = 3
    
    @State var glucoseSamples: [Int: (Date, [MetricSample])] = [:]
    @State var insulinSamples: [Int: (Date, [MetricSample])] = [:]
    
    func drawGlucoseAggs() -> some View {
        // Calculate ranges and step sizes
        Text("Not implemented")
            .frame(height:250)
    }
    
    func drawInsulinAggs() -> some View {
        Text("Not implemented")
            .frame(height:250)
    }
    
    var noData: some View {
        VStack(alignment: .center) {
            Image(systemName: "tray.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary.opacity(0.5))
                .font(.system(size: 30, weight: .ultraLight))
                .frame(width: 80)
            
            Text("No data")
                .font(.title)
            
            HStack(alignment: .center){
                Spacer()
                Text("Log an event")
                    .font(.body)
                Spacer()
            }
        }
    }
    
    func statistics(events: [Event]) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Glucose statistics")
                    .font(.headline)
                    .padding()
                Text("total events: \(events.count)")
                    .font(.subheadline)
            }
            if events.count > 0 {
                drawGlucoseAggs()
            } else {
                noData
            }
            
            HStack {
                Text("Insulin statistics")
                    .font(.headline)
                    .padding()
                Text("total events: \(events.count)")
                    .font(.subheadline)
            }
            if events.count > 0 {
                drawInsulinAggs()
            } else {
                noData
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(uiColor: UIColor.systemBackground))
        .cornerRadius(15)
    }
    
    func eventsList(events: [Event]) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Meal events")
                    .font(.headline)
                    .padding()
                Text("total events: \(events.count)")
                    .font(.subheadline)
            }
            if events.count > 0 {
                ForEach(events, id: \.id) { event in
                    NavigationLink(destination: {
                        MetricView(
                            metricStore: metricStore,
                            meal: meal,
                                event: event,
                                image: image
                            )
                            .environmentObject(eventStore)
                    }) {
                        HStack {
                            Text(formatDate(date: event.date))
                            Spacer()
                            Image(systemName: "arrow.forward.circle")
                        }
                        .padding()
                    }
                    MetricGraph(metricStore: metricStore, event: event, dataType: .Glucose, hours: hours)
                        .frame(height: 200)
                }
            } else {
                noData
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(5)
        .background(Color(uiColor: UIColor.systemBackground))
        .cornerRadius(15)
    }
    
    var body: some View {
        let mealEvents = eventStore.getEvents(mealId: meal.id)
        return NavigationView {
            GeometryReader { geo in
                ScrollView {
                    MealCard(
                        font: .largeTitle,
                        meal: meal,
                        image: image
                    )
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
                        
                        statistics(events: mealEvents)
                        eventsList(events: mealEvents)
                        
                    }
                }
                
            }
            .overlay {
                GeometryReader { _ in
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {showLogMeal.toggle() }) {
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
            .navigationTitle(Text("Meal details"))
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink("Edit"){
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
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.2))
            .bottomSheet(isPresented: $showLogMeal, detents: [.medium()]) {
                MealEventLogger(meal: meal)
                        .environmentObject(eventStore)
            }
            .onAppear {
                loadSamples(events: mealEvents)
            }
        }
        
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, yyyy-MM-dd hh:mm"
        return dateFormatter.string(from: date)
        
    }
    

    func loadSamples(events: [Event]) {
        glucoseSamples = [:]
        insulinSamples = [:]
        // TODO: Overlaps?
        events.forEach{ event in
            let start = event.date
            let end = event.date.advanced(by: TimeInterval(hours * 60 * 60))
            metricStore.getGlucoseSamples(start: start,end: end) { result in
                switch result {
                case .success(let samples):
                    glucoseSamples[event.id] = (event.date, samples)
                case .failure(let error):
                    print("Error \(error)")
                }
                
            }
            metricStore.getInsulinSamples(
                start: start,
                end: end
            ){ result in
                switch result {
                case .success(let samples):
                    insulinSamples[event.id] = (event.date, samples)
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
    
    @State var showErrorAlert:Bool = false
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
                Button("Cancel", role:.cancel){
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
        let store = Store(
                meals: [exampleMeal],
                events: [
                    Event(meal_id: mealID),
                    Event(meal_id: mealID),
                    Event(meal_id: mealID),
                    Event(meal_id: mealID)
                ],
                settings: Settings(dataSourceType: .HealthKit)
            )
        MealDetails(metricStore: store.metricStore, meal: exampleMeal)
            .environmentObject(store)
    }
}
