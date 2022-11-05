//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit
import AAInfographics

enum DataType {
    case Insulin
    case Glucose
}

let ranges: [DataType: (Double, Double)] = [
    .Insulin: (0, 10),
    .Glucose: (40, 400)
]

let glucoseGradientColors = [
    Color(hex: 0x360033),
    Color(hex: 0x0b8793)]

let insulinGradient = [
    Color(hex: 0x135058),
    Color(hex: 0xf1f2b5)
]

struct MetricGraph: View {
    var metricStore: MetricStore
    
    @State var samples: [MetricSample] = []
    @State var isAuthorized = false
    @State var debug = false
    @State var error: Error? = nil
    @State var loading = false
    
    var event: Event
    var dataType: DataType
    var hours: Int
    
    var body: some View {
        VStack {
            if debug {
                switch dataType {
                case .Insulin:
                    Text("Insulin Samples: \(samples.count)")
                case .Glucose:
                    Text("Glucose Samples: \(samples.count)")
                }
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            if loading {
                ProgressView()
            } else if !samples.isEmpty {
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
            } else {
                VStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .center) {
                            Image(systemName: "tray.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.secondary.opacity(0.5))
                                .font(.system(size: 30, weight: .ultraLight))
                                .frame(width: 50)
                            
                            Text("No data")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    Spacer()
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
        if debug {
            return
        }
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
        Group {
            VStack {
                MetricGraph(
                    metricStore: metricStore,
                    samples: glucoseSamples,
                    event: Event(meal_id: 1),
                    dataType: .Glucose,
                    hours: 3
                )
                .frame(width: 300, height: 300)
                MetricGraph(
                    metricStore: metricStore,
                    samples: insulinSamples,
                    event: Event(meal_id: 1),
                    dataType: .Insulin,
                    hours: 3
                )
                .frame(width: 300, height: 300)
            }
            
        }
    }
}
