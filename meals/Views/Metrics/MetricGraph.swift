//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit

enum DataType {
    case Insulin
    case Glucose
}

let ranges: [DataType: (Double, Double)] = [
    .Insulin: (0,10),
    .Glucose: (40, 400)
]

let glucoseGradientColors =  [
    Color(hex: 0x360033),
    Color(hex: 0x0b8793)]

let insulinGradient =  [
    Color(hex: 0x135058),
    Color(hex: 0xf1f2b5)
]

struct MetricGraph: View {
    @EnvironmentObject var store: Store
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
                    Text("Insulin Samples: \( samples.count )")
                case .Glucose:
                    Text("Glucose Samples: \( samples.count )")
                }
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            if loading {
                ProgressView()
            } else {
                let start = event.date
                let end = event.date.advanced(by: TimeInterval(hours)*60*60)
                switch dataType {
                case .Insulin:
                    ValueStats(eventSamples: [event.id: (event.date, samples)],
                               start: start,
                               end: end,
                               dateStepSizeMinutes: 30,
                               valueMin: 0 ,
                               valueStepSize: 0.5,
                               valueMax: 3,
                               valueColor: { _ in Color.accentColor }
                    )
                case .Glucose:
                    ValueStats(eventSamples: [event.id: (event.date,samples)],
                               start: start,
                               end: end,
                               dateStepSizeMinutes: 30,
                               valueMin: 75 ,
                               valueStepSize: 25,
                               valueMax: 300,
                               valueColor: { value in
                        if value < 70 {
                            return .red
                        } else if value  <  180 {
                            return  .green
                        } else if value < 250 {
                            return  .red
                        } else {
                            return  Color(hex: 0x600000)
                        }
                    })
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
    
    func loadSamples(event: Event, hours: Int){
        if debug {
            return
        }
        let hoursInSeconds = 60*60*TimeInterval(hours)
        let start = event.date
        let end = event.date.advanced(by: hoursInSeconds)
        switch self.dataType {
        case .Glucose:
            store.glucoseAPI().getGlucoseSamples(start: start, end: end) { result in
                switch result {
                case .success(let samples):
                    self.samples =  samples
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
                loading = false
            }
        case .Insulin:
            // We would like to fetch all insulin delivery which might be still
            // active
            let insulinActiveTime: TimeInterval = hoursInSeconds
            let start = event.date.advanced(by: -1 * insulinActiveTime)
            let end = event.date.advanced(by: insulinActiveTime)
            
            store.glucoseAPI().getInsulinSamples(start: start, end: end) { result in
                switch result {
                case .success(let samples):
                    self.samples = samples
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
                loading = false
            }
        }
        
    }
    
    

    
    func glucoseColors(point: GraphPoint) -> Color {
        if dataType == .Glucose {
            if point.value > 180 || point.value < 70 {
                return Color.red
            }
        }
        return Color.white
    }
    
    func range(samples: [MetricSample], min: Double, max:Double) -> (Double, Double){
        if samples.count == 0 {
            return (min, max)
        }
        let samplesMin = round(samples.min(by: {$0.value < $1.value})!.value)
        let sampleMax = round(samples.max(by: {$0.value < $1.value})!.value)
        
        if samplesMin == sampleMax {
            return (min, max)
        }
        
        return (samplesMin, sampleMax)
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
        Group {
            MetricGraph(
                samples: glucoseSamples,
                debug: true,
                event: Event(meal_id: 1),
                dataType: .Glucose,
                hours: 3
            )
            .frame(width: 300, height: 300)
            //            TODO: Insulinc
            //            MetricGraph(
            //                event: Event(meal_id: 1),
            //                dataType: .Insulin,
            //                samples: insulinSamples,
            //                samplesAndRange: SamplesAndRange(samples: glucoseSamples, start: glucoseSamples[0]!.date!),
            //                samplesAndRange: SamplesAndRange(samples: glucoseSamples,
            //                                                 start: Date.now),
            //                debug: true,
            //                debug: true,
            //                hours: 3
            //            )
            //            .frame(width: 300, height: 300)
        }
    }
}
