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
            } else {
                let stepSize:TimeInterval = 15*60
                let stepCount: Int = (hours*60*60) / Int(stepSize)
                let indexFormatter = timeIndexFormatter(stepSize: stepSize)
                let chartData: [ChartData] = Dictionary(grouping: samples.map {
                    ChartData(
                        index: ceil($0.date.timeIntervalSince(event.date) / stepSize),
                        valueMin: $0.value,
                        valueMax: $0.value
                    )
                }, by: \.index)
                    .values
                    .reduce([], { result, elements in
                        var newResult: [ChartData] = Array(result)
                        newResult.append(
                            elements.reduce(elements[0], {x,y in
                                ChartData(
                                    index: x.index,
                                    valueMin: min(x.valueMin, y.valueMin),
                                    valueMax: max(x.valueMax, y.valueMax)
                                )
                            })
                        )
                        return newResult
                    })
                
                
                
                switch dataType {
                case .Insulin:
                    Chart(
                        data: chartData,
                        startIndex: 0, endIndex: stepCount, indexStepSize: 3,
                        indexFormatter: indexFormatter,
                        startValue: 0, endValue: 5, valueStepSize: 1,
                        color: .blue)
                    .padding(.leading)
                    .frame(height: 200)
                case .Glucose:
                    let endValue = max(
                        300,
                        chartData.max(by: { $0.valueMax > $1.valueMax })?.valueMax ?? 0
                    )
                    Chart(
                        data: chartData,
                        startIndex: 0, endIndex: stepCount, indexStepSize: 3,
                        indexFormatter: indexFormatter,
                        startValue: 50, endValue: endValue, valueStepSize: 50,
                        color: .green)
                    .padding(.leading)
                    .frame(height: 200)
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

    func timeIndexFormatter(stepSize: TimeInterval) -> (Int) -> String {
        return { index in
            if index == 0 {
                return "0:00"
            }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .positional
            let formatted = formatter.string(from: Double(index)*stepSize)!
            if formatted.count < 3 {
                return "0:\(formatted)"
            }
            return formatted
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
//          let insulinActiveTime: TimeInterval = hoursInSeconds
            let start = event.date
            let end = event.date.advanced(by: hoursInSeconds)

            metricStore.getInsulinSamples(start: start, end: end) { result in
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

    func range(samples: [MetricSample], min: Double, max: Double) -> (Double, Double) {
        if samples.count == 0 {
            return (min, max)
        }
        let samplesMin = round(samples.min(by: { $0.value < $1.value })!.value)
        let sampleMax = round(samples.max(by: { $0.value < $1.value })!.value)

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
                    metricStore: Store().metricStore,
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
