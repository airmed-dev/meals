//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit
import AAInfographics

struct GlucoseInsulinGraph: View {
    var metricStore: MetricStore
    
    @State var insulinSamples: [MetricSample] = []
    @State var glucoseSamples: [MetricSample] = []
    
    @State var isAuthorized = false
    @State var debug = false
    @State var error: Error? = nil
    @State var loading = false
    
    var event: Event
    var hours: Int
    
    var body: some View {
        VStack {
            if loading {
                ProgressView()
            } else {
                if glucoseSamples.isEmpty && insulinSamples.isEmpty {
                    NoDataView(title: "No health data")
                } else {
                    if glucoseSamples.isEmpty {
                        NoDataView(title: "No health data")
                        Spacer()
                    } else{
                        GlucoseChart(start: event.date,
                                     end: event.date.advanced(
                                        by: TimeInterval(hours*60*60)
                                     ),
                                     samples: glucoseSamples
                        )
                    }
                    
                    
                    if insulinSamples.count == 0 {
                        NoDataView(title: "No health data")
                    } else {
                        InsulinChart(
                            start: event.date,
                            end: event.date.addingTimeInterval(
                                TimeInterval(60*60*hours)
                            ),
                            samples: insulinSamples
                        )
                    }
                }
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
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
        if debug {
            return
        }
        let hoursInSeconds = 60 * 60 * TimeInterval(hours)
        let start = event.date
        let end = event.date.advanced(by: hoursInSeconds)
        
        // Load glucose
        metricStore.getGlucoseSamples(
            start: start,
            end: end
        ) { result in
            switch result {
            case .success(let samples):
                self.glucoseSamples = samples
                self.error = nil
            case .failure(let error):
                self.error = error
            }
            loading = false
        }
        
        
        metricStore.getInsulinSamples(
            start: start,
            end: end
        ) { result in
            switch result {
            case .success(let samples):
                self.insulinSamples = calculateIOB(insulinDelivery: samples, start: start, end: end)
                self.error = nil
            case .failure(let error):
                self.error = error
            }
            loading = false
        }
        
    }
}


struct GlucoseInsulinGraph_Previews: PreviewProvider {
    static var insulinSamples = [
        MetricSample(Date.init(timeIntervalSinceNow: 0 * 60 * 60), 5),
        MetricSample(Date.init(timeIntervalSinceNow: 1 * 60 * 60), 2),
        MetricSample(Date.init(timeIntervalSinceNow: 2 * 60 * 60), 1)
    ]
    
    static var glucoseSamples = [
        MetricSample(Date.init(timeIntervalSinceNow: 0), 300),
        MetricSample(Date.init(timeIntervalSinceNow: 50 * 60), 200),
    ]
    static var previews: some View {
        let metricStore = Debug()
        let noDataMetricStore = Debug(noData: true)
        Group {
            VStack {
                GlucoseInsulinGraph(
                    metricStore: metricStore,
                    event: Event(meal_id: 1),
                    hours: 3
                )
                .frame(width: 300, height: 300)
            }
            
            VStack {
                GlucoseInsulinGraph(
                    metricStore: noDataMetricStore,
                    event: Event(meal_id: 1),
                    hours: 3
                )
                .frame(width: 300, height: 300)
            }
        }
    }
}
