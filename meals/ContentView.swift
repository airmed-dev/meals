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
            MealList()
                    .tabItem {
                        Label("Meals", systemImage: "circle.hexagongrid.circle")
                    }
                    .environmentObject(store)
            EventList()
                    .tabItem {
                        Label("Events", systemImage: "calendar.day.timeline.leading")
                    }
                    .environmentObject(store)
            SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .environmentObject(store)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
