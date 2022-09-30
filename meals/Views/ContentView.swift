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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
