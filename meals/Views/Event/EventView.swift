//
//  MetricView.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import BottomSheet

enum HealthkitError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
}

let threeHours: Double = 3 * 60 * 60

struct EventView: View {
    var metricStore: MetricStore
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.presentationMode) var presentationMode
    
    @State var meal: Meal
    @State var event: Event
    @State var image: UIImage?
    
    @State var fetchInsulin: Bool = false
    @State var hours: Int = 6
    let hourOptions = [3, 6]
    var width: CGFloat = 5
    
    // Notification state
    @State var showDeleteConfirmation: Bool = false
    
    // Edit sheet
    @State var showEditSheet: Bool = false
    @State var newDate: Date = Date.now
    
    // Alert
    @State var showSucessAlert: Bool = false
    @State var successMessage: String = ""
    
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) {
                    mealImage
                    
                    VStack(alignment: .leading) {
                        mealEventPropertiesView
                        Divider()
                        metricsView
                            .frame(height: geo.size.height/2)
                    }
                    .background(.background)
                    
                    buttonsView
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(title: Text("Are you sure you want to delete this event?"),
                          primaryButton: .destructive(Text("Yes")) {
                        deleteEvent()
                    }, secondaryButton: .cancel())
                }
                .alert(successMessage, isPresented: $showSucessAlert) {
                    Button("OK", role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .alert("Error: \(errorMessage)", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) {
                    }
                }
                .bottomSheet(isPresented: $showEditSheet) {
                    UpdateEventView(event: $event, newDate: newDate)
                        .environmentObject(eventStore)
                }
            }
        }
                .background(Color(.systemGray6))
    }
    
    var mealImage: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                NoPhotoView()
            }
        }
    }
    
    var mealEventPropertiesView: some View {
        VStack(alignment: .leading) {
            Text(meal.name)
                .font(.title)
                .fontWeight(.bold)
                .minimumScaleFactor(1)
                .padding(.leading)
                .padding(.top, 5)
            
            Text("Consumed at: " + event.date.formatted())
                .font(.footnote)
                .foregroundColor(.black.opacity(1.00))
                .padding(.leading)
            
            Divider()
            Text(meal.description)
                .padding(.leading)
            
        }
    }
    
    var metricsView: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Metrics")
                    .font(.title2)
                    .padding(15)
                
                Spacer()
                
                Picker("Hours", selection: $hours) {
                    ForEach(hourOptions, id: \.self) { hour in
                        Text("\(hour) hours")
                    }
                }
            }
            GlucoseInsulinGraph(
                metricStore: metricStore,
                event: event,
                hours: hours
            )
        }
        .cornerRadius(15)
    }
    
    var buttonsView: some View {
        HStack {
            Text("Edit").onTapGesture {
                showEditSheet = true
            }
            .foregroundColor(.accentColor)
            
            Spacer()
            Text("Delete").onTapGesture {
                showDeleteConfirmation = true
            }
            .foregroundColor(.red)
        }
        .padding(15)
    }
    
    func deleteEvent() {
        do {
            try eventStore.deleteEvent(eventId: event.id)
            showSucessAlert = true
            successMessage = "Event deleted"
        } catch {
            showErrorAlert = true
            errorMessage = "Failed deleting event: \(error)"
        }
    }
    
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        let longDescription = """
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
abcdefg
"""
        let mealID: Int = 0
        let metricStore = Debug()
        let noDataMetricStore = Debug(noData:true)
        Group {
            EventView(
                metricStore: metricStore,
                meal: Meal( id: mealID, name: "Blueberries", description: "short description"),
                event: Event(meal_id: mealID, id: 3, date: Date.now)
            )
            EventView(
                metricStore: metricStore,
                meal: Meal( id: mealID, name: "Blueberries", description: longDescription),
                event: Event(meal_id: mealID, id: 3, date: Date.now)
            )
            EventView(
                metricStore: noDataMetricStore,
                meal: Meal( id: mealID, name: "Meal without health data and a long name", description: "banana"),
                event: Event(meal_id: mealID, id: 3, date: Date.now)
            )
            EventView(
                metricStore: metricStore,
                meal: Meal(id: mealID, name: "Blueberries and a lot of delicious", description: "Yes yes yes"),
                event: Event(meal_id: mealID, id: 3, date: Date.now),
                showDeleteConfirmation: true,
                showEditSheet: false
            )
            EventView(metricStore: metricStore,
                      meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
                      event: Event(meal_id: mealID, id: 3, date: Date.now),
                      showDeleteConfirmation: false,
                      showEditSheet: true
            )
            EventView(metricStore: metricStore,
                      meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
                      event: Event(meal_id: mealID, id: 3, date: Date.now),
                      showDeleteConfirmation: false,
                      showEditSheet: true,
                      showSucessAlert: true
            )
        }
    }
}

