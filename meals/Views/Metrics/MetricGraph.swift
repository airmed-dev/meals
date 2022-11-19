//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit
import AAInfographics


struct MetricGraph: View {
    var metricStore: MetricStore
    
    @State private var samples: [MetricSample] = []
    @State var error: Error? = nil
    @State var loading = false
    
    var hideTitle: Bool = false
    var event: Event
    var dataType: DataType
    var hours: Int
    
    var body: some View {
        VStack {
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            if loading {
                ProgressView()
            } else if samples.isEmpty {
                if !hideTitle {
                    Text(dataType.description)
                }
                NoDataView(
                    title: "No health data",
                    titleFont: .title3,
                    iconSize: 40
                )
            } else {
                switch dataType {
                case .Insulin:
                    InsulinChart(
                        start: event.date,
                        end: event.date.addingTimeInterval(TimeInterval(60*60*hours)),
                        samples: samples
                    )
                case .Glucose:
                    GlucoseChart(start: event.date,
                                 end: event.date.advanced(by: TimeInterval(hours*60*60)),
                                 samples: samples
                    )
                }
                
            }
        }
        .onAppear {
            loadSamples(event: event, hours: hours)
        }
        .onChange(of: event) { newEvent in
            loadSamples(event: newEvent, hours: hours)
        }
        .onChange(of: hours) { newHours in
            loadSamples(event: event, hours: newHours)
        }
    }
    
    func loadSamples(event: Event, hours: Int) {
        let hoursInSeconds = 60 * 60 * TimeInterval(hours)
        let start = event.date
        let end = event.date.advanced(by: hoursInSeconds)
        switch dataType {
        case .Glucose:
            metricStore.getGlucoseSamples(start: start, end: end) { result in
                switch result {
                case .success(let samples):
                    self.samples = samples
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
                loading = false
            }
        case .Insulin:
            let start = event.date
            let end = event.date.advanced(by: hoursInSeconds)
            
            metricStore.getInsulinSamples(start: start, end: end) { result in
                switch result {
                case .success(let samples):
                    self.samples = calculateIOB(insulinDelivery: samples, start: start, end: end)
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
                loading = false
            }
        }
        
    }
}


struct MetricGraph_Previews: PreviewProvider {
    static var previews: some View {
        let metricStore = Debug()
        let noDataMetricStore = Debug(noData: true)
        Group {
            VStack {
                MetricGraph(
                    metricStore: metricStore,
                    event: Event(meal_id: 1),
                    dataType: .Glucose,
                    hours: 3
                )
                .frame(width: 300, height: 300)
                MetricGraph(
                    metricStore: metricStore,
                    event: Event(meal_id: 1),
                    dataType: .Insulin,
                    hours: 3
                )
                .frame(width: 300, height: 300)
                
            }
            
            VStack {
                MetricGraph(
                    metricStore: noDataMetricStore,
                    event: Event(meal_id: 1),
                    dataType: .Glucose,
                    hours: 3
                )
                .frame(width: 300, height: 300)
                MetricGraph(
                    metricStore: noDataMetricStore,
                    event: Event(meal_id: 1),
                    dataType: .Insulin,
                    hours: 3
                )
                .frame(width: 300, height: 300)
            }
        }
    }
}
