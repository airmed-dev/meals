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
    @State var ready = false
    
    // Meal event logging
    @State var showMealSelector = false
    @State var showLogEventAlert = false
    @State var mealToLog: Meal? = nil
    @State var mealEventDate: Date = Date()
    
    // Meal event logging alerts
    @State var showMealSuccessAlert = false
    
    // Event statistics
    @State var selectedEvent: Event? = nil
    @State var hours = 3
    
    
    
    var body: some View {
        VStack {
            if !ready {
                headerSkeleton
                statisticsSkeleton
                timelineSkeleton
            } else {
                header
                statistics
                timeline
            }
        }
        .onAppear {
            withAnimation {
                ready = true
                selectedEvent = viewModel.events.first
            }
        }
    }
    var header: some View {
        let colors = [Color(hex:0x424242), Color(hex:0x002266)]
        let meal = selectedEvent != nil
            ? viewModel.getMeal(event: selectedEvent!)!
            : nil
        let image = meal != nil
            ? viewModel.loadImage(meal: meal!)
            : nil


        return HStack {
            if let selectedEvent = selectedEvent {
                // TODO: loadImage(event: event?)
                if let image=image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100,  height: 100)
                        .clipShape(Circle())
                } else{
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: 100, height: 100)
                }
                VStack {
                    Spacer()
                    HStack{
                        Text(meal!.name)
                            .font(.headline)
                        Spacer()
                    }
                    HStack{
                        Text("\(formatDate(date:selectedEvent.date)) at \(formatTime(date: selectedEvent.date))")
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            } else {
                VStack{
                    Spacer()
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: 100, height: 100)
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack{
                        Text("No event is selected")
                            .font(.headline)
                            .frame(height: 30)
                    }
                    HStack{
                        Text("Select an event in the timeline")
                            .font(.caption)
                            .frame(height: 10)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(height: 130)
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
            if let selectedEvent = selectedEvent {
                glucoseStatistics(event: selectedEvent)
                insulinStatistics(event: selectedEvent)
            } else {
                glucoseStatisticsSkeleton
                insulinStatisticsSkeleton
            }
        }
    }
    
    func glucoseStatistics(event: Event) -> some View {
        return VStack {
            HStack {
                Text("Glucose")
                    .font(.subheadline)
                    .padding(.leading, 5)
                Spacer()
            }
            MetricGraph(event: event, dataType: .Glucose, hours: hours)
            Spacer()
        }
    }
    
    func insulinStatistics(event: Event) -> some View {
        return VStack {
            HStack {
                Text("Insulin")
                    .font(.subheadline)
                    .padding(.leading, 5)
                Spacer()
            }
            MetricGraph(event: event, dataType: .Insulin, hours: hours)
            Spacer()
        }
    }
    
    var timeline: some View {
        let timelineEvents = getTimelineEvents()
        return VStack {
            HStack {
                Text("Timeline")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                    .padding(.leading, 10)
                Spacer()
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 25)
                    .frame(height: 25)
                    .overlay {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                            .padding()
                    }
                    .onTapGesture {
                       showMealSelector = true
                    }
            }
            .bottomSheet(isPresented: $showMealSelector, detents: [.large()]){
                mealSelector
                    .environmentObject(viewModel)
            }
            .frame(height: 20)
            .padding(.trailing, 10)
            .alert(isPresented: $showMealSuccessAlert){
                Alert(title: Text("Save"))
            }

            
            HStack {
                if viewModel.events.isEmpty{
                   noData
                } else {
                    ScrollView(.horizontal){
                        HStack {
                            ForEach(Array(timelineEvents.enumerated()), id: \.1.hashValue){ index, timelineEvent in
                                timelineCard(
                                    meal: viewModel.getMeal(event: timelineEvent.event)!,
                                    event: timelineEvent.event,
                                    firstInDay:
                                        index == 0 || !isSameDay(
                                            date1: timelineEvents[index-1].event.date,
                                            date2: timelineEvent.event.date
                                        )
                                )
                                .onTapGesture{
                                    withAnimation {
                                        selectedEvent = timelineEvent.event
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 150)
            .padding(.top, 5)
            .padding(.bottom, 15)
            .padding(.leading, 3)
            .padding(.trailing, 3)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(15)
        }
    }
    
    func mealEventLogger(meal: Meal) -> some View {
        return VStack {
            MealCard(
                font: .largeTitle,
                meal: meal,
                image: viewModel.loadImage(meal: meal)
            )
            .clipShape(
                RoundedRectangle(
                    cornerSize: CGSize(width: 10, height: 10)))
            .padding()
            
            Spacer()
            
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    DatePicker("Meal time", selection: $mealEventDate)
                    Spacer()
                    Button(action: {
//                        viewModel.saveEvent(event: Event(meal_id: meal.id, id: 0, date: mealEventDate))
                        showMealSuccessAlert = true
                    }){
                        HStack {
                            Spacer()
                            Text("Save")
                            Spacer()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(Text("New meal event"))

        
    }
    
    var mealSelector: some View {
        let twoColumns = [GridItem(.flexible()), GridItem(.flexible())]
        return NavigationView {
            VStack {
                LazyVGrid(columns: twoColumns) {
                    ForEach(viewModel.meals, id: \.hashValue){ meal in
                        NavigationLink(destination: mealEventLogger(meal: meal)) {
                            MealCard(
                                font: .headline,
                                meal: meal,
                                image: viewModel.loadImage(meal: meal)
                            )
                            .frame(width: 150,height: 150)
                            .clipShape(
                                RoundedRectangle(
                                    cornerSize: CGSize(width: 10, height: 10)))
                            .padding()
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Log")
        }
    }
    
    func timelineCard(meal: Meal, event: Event, firstInDay: Bool) -> some View {
        VStack {
            HStack {
                if firstInDay {
                    Text(formatDate(date: event.date))
                }
                Spacer()
            }
            Spacer()
            HStack {
                Text(formatTime(date: event.date))
                    .font(.caption)
                    .padding(0)
                Spacer()
            }
            MealCard(
                font: .caption,
                meal: meal,
                image: viewModel.loadImage(meal: meal)
            )
            .clipShape(
                RoundedRectangle(
                    cornerSize: CGSize(width: 10, height: 10)))
            .frame(width: 100, height: 100)
        }
        .padding(.leading, 10)
        .padding(.bottom, 5)
    }
    
    var noData: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center) {
                Image(systemName: "tray.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary.opacity(0.5))
                    .font(.system(size: 30, weight: .ultraLight))
                    .frame(width: 80)
                
                Text("No data")
                    .font(.title)
                
                HStack(alignment: .center){
                    Spacer()
                    Text("Log an event")
                        .font(.body)
                    Spacer()
                }
            }
            Spacer()
        }
        
    }
    
    // Skeletons sections
    var headerSkeleton: some View {
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
    
    var statisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Statistics")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.leading, 5)
                Spacer()
            }
            withAnimation(.spring()){
                glucoseStatisticsSkeleton
            }
            insulinStatisticsSkeleton
                .animation(.spring())
        }
    }
    
    var timelineSkeleton: some View {
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
                    timelineCardSkeleton(true)
                    timelineCardSkeleton()
                    timelineCardSkeleton()
                    timelineCardSkeleton(true)
                    timelineCardSkeleton()
                }
            }
            .frame(height: 150)
            .padding(.top, 5)
            .padding(.bottom, 15)
            .padding(.leading, 3)
            .padding(.trailing, 3)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(15)
        }
    }
    

    // Skeleton subcomponenets
    var glucoseStatisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Glucose")
                    .font(.subheadline)
                    .padding(.leading, 5)
                Spacer()
            }
            statisticsGraphSkeleton
            Spacer()
        }
    }
    
    var insulinStatisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Insulin")
                    .font(.subheadline)
                    .padding(.leading, 5)
                Spacer()
            }
            statisticsGraphSkeleton
            Spacer()
        }
    }
    
    var statisticsGraphSkeleton: some View {
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
    
    func timelineCardSkeleton(_ displayDateSkeleton: Bool = false) -> some View {
        VStack {
            VStack {
                if displayDateSkeleton {
                    textSkeleton
                }
            }
            .frame(height: 10)
            
            textSkeleton
                .frame(height: 10)
            Rectangle()
                .foregroundColor(Color(uiColor: .systemGray5))
                .cornerRadius(10)
                .frame(width: 100)
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
    
    // Event handler
    func onMealTap(meal: Meal){
        showLogEventAlert = true
        mealToLog = meal
    }
    
    // Helpers
    func isSameDay(date1: Date, date2: Date) -> Bool {
        return Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }
    
    func formatTime(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
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
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: date)
    }
    
    func getTimelineEvents() -> [TimelineEvent] {
        viewModel.events.map {
            TimelineEvent(
                event: $0,
                mealUpdatedAt: viewModel.getMeal(event: $0)!.updatedAt
            )
        }
    }
    
}

struct TimelineEvent: Hashable {
    var event:Event
    var mealUpdatedAt: Date
}

struct EventList_Previews: PreviewProvider {
    
    static var previews: some View {
        let mealUUID = 1
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
