//
//  ContentView.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @ObservedObject var store = Store()
    
    // Loading error alert
    @State var showErrorAlert = false
    @State var errorMessage = ""

    var body: some View {
        TabView {
            MealList(metricStore: store.metricStore)
                    .tabItem {
                        Label("Meals", systemImage: "circle.hexagongrid.circle")
                    }
                    .environmentObject(store.mealStore)
                    .environmentObject(store.photoStore)
                    .environmentObject(store.eventStore)
            EventList(metricStore: store.metricStore)
                    .tabItem {
                        Label("Events", systemImage: "calendar.day.timeline.leading")
                    }
                    .environmentObject(store.mealStore)
                    .environmentObject(store.photoStore)
                    .environmentObject(store.eventStore)
            SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .environmentObject(store.settingsStore)

        }
        .onAppear {
            do {
                try store.load()
            } catch {
                showErrorAlert = true
                errorMessage = "Failed loading settings: \(error)"
            }
        }
        .alert(isPresented: $showErrorAlert){
            Alert(title: Text("Error"), message: Text(errorMessage+"\nRestart the app"), dismissButton: .cancel(Text("Exit"), action: {
                exit(-1)
            }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
