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
    // Onboarding view
    @State var showOnBoarding = false
    
    // Loading error alert
    @State var showErrorAlert = false
    @State var errorMessage = ""

    var body: some View {
        TabView {
            EventList()
                    .tabItem {
                        Label("Events", systemImage: "calendar.day.timeline.leading")
                    }
                    .environmentObject(store.mealStore)
                    .environmentObject(store.photoStore)
                    .environmentObject(store.eventStore)
            MealList()
                    .tabItem {
                        Label("Meals", systemImage: "circle.hexagongrid.circle")
                    }
                    .environmentObject(store.mealStore)
                    .environmentObject(store.photoStore)
                    .environmentObject(store.eventStore)

            SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }

        }
        .onAppear {
            // Load data
            do {
                try store.load()
            } catch {
                showErrorAlert = true
                errorMessage = "Failed loading settings: \(error)"
            }
            
            // Check for onboarding
            let defaults = UserDefaults()
            showOnBoarding = !defaults.bool(forKey: "onboarding.done")
        }
        .sheet(isPresented: $showOnBoarding){
           OnboardingView()
        }
        .alert(isPresented: $showErrorAlert){
            Alert(
                title: Text("Error"),
                message: Text(errorMessage+"\nRestart the app"),
                dismissButton: .cancel(
                    Text("Exit"),
                    action: { exit(-1) }
                )
            )
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
