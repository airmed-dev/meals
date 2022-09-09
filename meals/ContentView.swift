//
//  ContentView.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewViewModel()
    
    var body: some View {
        TabView {
            MealList()
                .tabItem {
                    Label("Meals", systemImage: "circle.hexagongrid.circle")
                }
                .environmentObject(viewModel)
            EventList()
                .tabItem {
                    Label("Events", systemImage: "calendar.day.timeline.leading")
                }
                .environmentObject(viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
