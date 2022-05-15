//
//  ContentView.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var newMealPresented = false
    
    var body: some View {
        MealList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
