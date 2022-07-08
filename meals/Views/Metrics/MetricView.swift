//
//  MetricView.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit
import Alamofire
import BottomSheet

enum HealthkitError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
}

let threeHours: Double = 3 * 60 * 60

struct MetricView: View {
    @Environment(\.presentationMode) var presentationMode
    
    
    @State var meal: Meal?
    @State var event: Event
    @State var image: UIImage?
    
    @State var fetchInsulin: Bool = false
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
        VStack{
            if let meal = meal {
                VStack {
                    HStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 150)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(height: 150)
                        }
                        
                        VStack {
                            Text(meal.name)
                                .font(.headline)
                            Text(event.date.ISO8601Format())
                                .font(.footnote)
                        }
                    }
                }
            }
            
            Spacer()
            List {
                Section {
                    Text("Glucose")
                    MetricGraph(event: event, dataType: .Glucose)
                        .frame(height: 200)
                        .border(.black)
                }
                Section {
                    Text("Insulin")
                    MetricGraph(event: event, dataType: .Insulin )
                        .frame(height: 200)
                        .border(.black)
                }
                Section {
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
                }
            }
        }
        .onAppear {
            if let meal = meal {
                PhotosAPI.getPhoto(meal: meal) { result in
                    switch result {
                    case .success(let loadedImage):
                        image = loadedImage
                    case .failure(let error):
                        showErrorAlert = true
                        errorMessage = "Failed loading image: \(error)"
                    }
                }
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
        }
    }
    
    func deleteEvent(){
        EventsAPI.deleteEvent(event: event) { result in
            switch result {
            case .success(_):
                showSucessAlert = true
                successMessage = "Event deleted"
            case .failure(let error):
                showErrorAlert = true
                errorMessage = "Failed deleting event: \(error.localizedDescription)"
            }
        }
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
                meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
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
        .padding()
    }
    
    func saveEvent(event: Event){
        let newEvent = Event(meal_id: event.meal_id, id: event.id, date: newDate)
        EventsAPI.saveEvent(event: newEvent){ result in
            print("Completion")
            switch result {
            case .success(_):
                showSuccessAlert = true
                successMessage = "Saved event"
            case .failure(let error):
                showErrorAlert = true
                errorMessage = "Failed saving event: \(error)"
            }
        }
    }
    
}
