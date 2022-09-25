//
//  MealDetails.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MealDetails: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var meal: Meal
    
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
                        MetricView(meal: meal, event: event)
                            .environmentObject(viewModel)
                    }) {
                        HStack {
                            Text(formatDate(date: event.date))
                            Spacer()
                            Image(systemName: "arrow.forward.circle")
                        }
                        .padding()
                    }
                    MetricGraph(event: event, dataType: .Glucose, hours: hours)
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
        let mealEvents = viewModel.getEvents(mealId: meal.id)
        return NavigationView {
            GeometryReader { geo in
                ScrollView {
                    MealCard(
                        font: .largeTitle,
                        meal: meal,
                        image: viewModel.loadImage(meal: meal)
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
                                    Text("Log event")
                                        .foregroundColor(.white)
                                }
                                .padding(15)
                                .background(.primary)
                                .cornerRadius(15)
                                //                    .clipShape(Circle())
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
                            image: viewModel.loadImage(meal: meal),
                            onEdit: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.2))
            .alert(isPresented: $showLogMeal) {
                let date = Date()
                return Alert(title: Text("Enter meal event at: \(formatDate(date:date))"),
                             primaryButton: .default(Text("Yes")){
                    createEvent(date: date)
                    loadSamples(events: viewModel.getEvents(mealId: meal.id))
                }, secondaryButton: .cancel())
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
    
    func createEvent(date: Date){
        let event = Event(meal_id: meal.id, id: 0, date: date)
        viewModel.saveEvent(event: event)
    }
    
    func loadSamples(events: [Event]) {
        glucoseSamples = [:]
        insulinSamples = [:]
        // TODO: Overlaps?
        events.forEach{ event in
            let start = event.date
            let end = event.date.advanced(by: TimeInterval(hours * 60 * 60))
            viewModel.glucoseAPI().getGlucoseSamples(start: start,end: end) { result in
                switch result {
                case .success(let samples):
                    glucoseSamples[event.id] = (event.date, samples)
                case .failure(let error):
                    print("Error \(error)")
                }
                
            }
            viewModel.glucoseAPI().getInsulinSamples(
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

struct MealDetails_Previews: PreviewProvider {
    static var previews: some View {
        let mealID = 1
        MealDetails(meal: MealStore.exampleMeal)
            .environmentObject(ContentViewViewModel(
                meals: [MealStore.exampleMeal],
                events: [
                    Event(meal_id: mealID),
                    Event(meal_id: mealID),
                    Event(meal_id: mealID),
                    Event(meal_id: mealID)
                ],
                settings: Settings(dataSourceType: .HealthKit)
            ))
    }
}
