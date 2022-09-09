//
//  EventList.swift
//  meals
//
//  Created by aclowkey on 01/06/2022.
//

import Foundation

import SwiftUI

struct EventList: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    
    @State var selectedEvent: Event?
    @State var preview = false
    
    @State var hours = 3
    @State var selectedMealPhoto: UIImage?
    @State var dateInView: Date?
    
    var body: some View {
        VStack {
            header
            statistics
            timeline
        }
    }
    
    var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(uiColor: .systemGray3))
            VStack {
                Spacer()
                HStack{
                    textSkeleton.frame(height: 30)
                    Spacer()
                }
                HStack{
                    textSkeleton
                        .frame(height: 10)
                    Spacer()
                }
                Spacer()
            }
            Spacer()
        }
        .frame(height: 100)
        .padding(.leading, 5)
    }
    
    var statistics: some View {
        VStack {
            HStack {
                Text("Statistics")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.leading, 5)
                Spacer()
            }
            glucoseStatistics
            insulinStatistics
        }
    }
    
    var timeline: some View {
        VStack {
            HStack {
                Text("Timeline")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                    .padding(.leading, 10)
                Spacer()
                Circle()
                    .foregroundColor(Color(uiColor: .systemGray3))
                    .frame(width: 25)
                    .frame(height: 25)
                    .overlay {
                        Image(systemName: "plus")
                            .padding()
                    }
            }
            .frame(height: 20)
            .padding(.trailing, 10)
            
            ScrollView(.horizontal){
                HStack {
                    timelineSkeleton
                    timelineSkeleton
                    timelineSkeleton
                    timelineSkeleton
                    timelineSkeleton
                    timelineSkeleton
                }
            }
            .padding(.top, 25)
            .padding(.bottom, 15)
            .padding(.leading, 3)
            .padding(.trailing, 3)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(15)
        }
    }
    
    var glucoseStatistics: some View {
        VStack {
            HStack {
                Text("Glucose")
                    .font(.subheadline)
                    .padding(.leading, 5)
                Spacer()
            }
            statisticsSkeleton
            Spacer()
        }
    }
    
    var insulinStatistics: some View {
        VStack {
            HStack {
                Text("Insulin")
                    .font(.subheadline)
                    .padding(.leading, 5)
                Spacer()
            }
            statisticsSkeleton
            Spacer()
        }
    }
    
    var statisticsSkeleton: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(uiColor: .systemGray6))
                .cornerRadius(15)
            GeometryReader { geo in
                ForEach(
                    Array(stride(from: 30, to: geo.size.width, by: geo.size.width/7)), id: \.self
                ) { index in
                    Rectangle()
                        .foregroundColor(Color(uiColor: .systemGray3))
                        .frame(width: 30, height: geo.size.height*0.8)
                        .cornerRadius(15)
                        .position(x: index, y: geo.size.height/2)
                }
            }
        }
        .padding(.leading, 3)
        .padding(.trailing, 3)
    }
    
    var timelineSkeleton: some View {
        VStack {
            textSkeleton
                .frame(height: 10)
            Rectangle()
                .foregroundColor(Color(uiColor: .systemGray5))
                .cornerRadius(10)
                .frame(width: 100, height: 100)
        }
        .padding(.leading, 10)
        .padding(.bottom, 5)
    }
    
    var textSkeleton: some View {
        HStack() {
            Rectangle()
                .foregroundColor(Color(uiColor: .systemGray3))
                .cornerRadius(10)
            Spacer()
        }
    }
    
    
    func formatAsDay(_ date:Date) -> String {
        if(Calendar.current.isDateInToday(date)){
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDate(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(date){
            return "Yesterday"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        
        return formatter.string(from: date)
    }
    
}

struct EventList_Previews: PreviewProvider {
    
    static var previews: some View {
        let mealUUID = 1
        let today = Date()
        EventList()
            .environmentObject( ContentViewViewModel(
                meals: [
                    Meal(id: mealUUID, name: "Test", description: "Test")
                ],
                events: [
                    Event(meal_id: mealUUID, id: 1),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                    Event(meal_id: mealUUID),
                ]
            ))
    }
}
