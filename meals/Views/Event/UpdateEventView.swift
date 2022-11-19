//
//  UpdateEventView.swift
//  meals
//
//  Created by aclowkey on 19/11/2022.
//

import SwiftUI

struct UpdateEventView: View {
    @EnvironmentObject var eventStore: EventStore
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
                Button("Save") {
                    saveEvent(event: event)
                }
                Spacer()
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            newDate = event.date
        }
        .alert(errorMessage, isPresented: $showErrorAlert) {
            Button("Ok", role: .cancel) { }
        }
        .alert(successMessage, isPresented: $showSuccessAlert) {
            Button("Ok", role: .cancel) {
                event.date = newDate
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func saveEvent(event: Event) {
        let newEvent = Event(meal_id: event.meal_id, id: event.id, date: newDate)
        do {
            try eventStore.saveEvent(event: newEvent)
            showSuccessAlert = true
            successMessage = "Saved event"
        } catch {
            showErrorAlert = true
            errorMessage = "Failed saving event: \(error)"
        }
    }
    
}


//
// TODO: Implement a preview
//struct UpdateEventView_Previews: PreviewProvider { }
