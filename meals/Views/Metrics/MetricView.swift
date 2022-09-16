//
//  MetricView.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import Alamofire
import BottomSheet

enum HealthkitError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
}

let threeHours: Double = 3 * 60 * 60

struct MetricView: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var meal: Meal?
    @State var event: Event
    @State var image: UIImage?
    
    @State var fetchInsulin: Bool = false
    @State var hours: Int = 6
    let hourOptions = [3,6]
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
        ScrollView{
            VStack(alignment: .leading) {
                if let meal = meal {
                    // Image section
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFill()
                    }
                    
                    // Overlapping card
                    VStack(alignment: .leading) {
                        // Meal properties
                        VStack(alignment: .leading) {
                            Text(meal.name)
                                .font(.system(size: 32))
                                .minimumScaleFactor(1)
                                .padding()
                            Text("Consumed at: " + event.date.formatted())
                                .font(.footnote)
                                .foregroundColor(.black.opacity(1.00))
                                .padding(EdgeInsets(top: -15, leading: 10, bottom: 15, trailing: 0))
                            HStack(alignment: .firstTextBaseline) {
                                Text(meal.description)
                            }
                            Divider()
                            HStack(alignment: .center) {
                                Text("Metrics")
                                    .font(.system(size: 32))
                                    .minimumScaleFactor(1)
                                    .padding(3)
                                
                                Spacer()
                                
                                Picker("Hours", selection: $hours ){
                                    ForEach(hourOptions, id: \.self){ hour in
                                        Text("\(hour) hours")
                                    }
                                }
                            }
                            .padding(3)
                        }
                        
                        VStack {
                            // Metrics
                            VStack() {
                                Text("Glucose - \(hours)")
                                    .font(.system(size: 18))
                                MetricGraph(event: event, dataType: .Glucose, hours: hours)
                                    .frame(height: 200)
                            }
                            .padding(5)
                            .cornerRadius(20)
                        
                            VStack() {
                                Text("Insulin")
                                    .font(.system(size: 18))
                                MetricGraph(event: event, dataType: .Insulin, hours: hours)
                                    .frame(height: 200)
                            }
                            .padding(5)
                            .cornerRadius(10)
                        }
                        .cornerRadius(15)
                        .offset(y: -10)
                    }
                    .background(.background)
                    .cornerRadius(30)
                    .offset(y: -30)
                }
                
                // Menus
                HStack {
                    Text("Edit").onTapGesture {
                        showEditSheet = true
                    }
                    .foregroundColor(.accentColor)
                    
                    Spacer()
                    Text("Delete") .onTapGesture {
                        showDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: CGFloat(10)))
                .padding()
            }
            .background(Color(.systemGray6))
            .frame(width: .infinity)
            .onAppear {
                if let meal = meal {
                    image = ContentViewViewModel.loadImage(meal: meal)
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(title: Text("Are you sure you want to delete this event?"),
                      primaryButton: .destructive(Text("Yes")){
                    deleteEvent()
                }, secondaryButton: .cancel())
            }
            .alert(successMessage, isPresented: $showSucessAlert){
                Button("OK", role: .cancel){
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .alert("Error: \(errorMessage)", isPresented: $showErrorAlert){
                Button("OK", role: .cancel){ }
            }
            .bottomSheet(isPresented: $showEditSheet ){
                UpdateEventView(event: $event, newDate: newDate)
                    .environmentObject(viewModel)
            }
        }
    }
    
    func deleteEvent(){
        viewModel.deleteEvent(eventId: event.id)
        showSucessAlert = true
        successMessage = "Event deleted"
    }
    
}

struct MetricView_Previews: PreviewProvider {
    static var previews: some View {
        let mealID:Int = 0
        Group {
            MetricView(
                meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
                event: Event(meal_id: mealID, id: 3, date: Date.now)
            )
            MetricView(
                meal: Meal(id: mealID, name: "Blueberries and a lot of delicious", description: "Yummy meal"),
                event: Event(meal_id: mealID, id: 3, date: Date.now),
                showDeleteConfirmation: true,
                showEditSheet: false
            )
            MetricView(
                meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
                event: Event(meal_id: mealID, id: 3, date: Date.now),
                showDeleteConfirmation: false,
                showEditSheet: true
            )
            MetricView(
                meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
                event: Event(meal_id: mealID, id: 3, date: Date.now),
                showDeleteConfirmation: false,
                showEditSheet: true,
                showSucessAlert: true
            )
        }
    }
}

struct UpdateEventView: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var event: Event
    @State var newDate: Date
    
    
    @State var showSuccessAlert: Bool = false
    @State var successMessage: String = "Updated event"
    
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Update event")
                .font(.headline)
                .padding()
            DatePicker("Event date", selection: $newDate, displayedComponents: [.date])
            DatePicker("Event time", selection: $newDate, displayedComponents: [.hourAndMinute])
            Spacer()
            HStack {
                Button("Save"){
                    saveEvent(event: event)
                }
                Spacer()
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .onAppear {
            newDate = event.date
        }
        .alert(errorMessage, isPresented: $showErrorAlert){
            Button("Ok", role: .cancel){}
        }
        .alert(successMessage, isPresented: $showSuccessAlert) {
            Button("Ok", role: .cancel){
                event.date = newDate
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func saveEvent(event: Event){
        let newEvent = Event(meal_id: event.meal_id, id: event.id, date: newDate)
        viewModel.saveEvent(event: newEvent)
        showSuccessAlert = true
        successMessage = "Saved event"
    }
    
}
