//
//  GlucoseRangeChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct GlucoseStatisticsChart: UIViewRepresentable {
    var samples: [(Date, [MetricSample])]
    
    init(samples: [(Date, [MetricSample])]){
        self.samples = samples
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let chartView = uiView as? AAChartView {
            let aaChartModel = getModel()
            chartView.aa_drawChartWithChartModel(aaChartModel)
        }
    }
    func makeUIView(context: Context) -> some UIView {
        let aaChartView = AAChartView()
        let aaChartModel = getModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        return aaChartView
    }
    
    func getModel() -> AAChartModel {
        let categories = getCategories()
        return AAChartModel()
            .categories(categories)
            .colorsTheme(["#6fc7fc", "#ced8de"])
            .legendEnabled(false)
            .series([
                AASeriesElement()
                    .type(.areasplinerange)
                    .name("50%")
                    .data(get50th())
                    .marker(AAMarker().radius(0))
                    .zIndex(1),
                AASeriesElement()
                    .type(.arearange)
                    .name("100%")
                    .lineWidth(5)
                    .marker(AAMarker().radius(0))
                    .data(get100th())
                    .zIndex(0)
        ])
    }
    
    func get100th() -> [[Double]]{
        let stepSize: TimeInterval = 60*60
        let samplesFromStart = samples.flatMap { eventSamples in
            eventSamples.1.map { sample in
                (
                    sample.date.timeIntervalSince(eventSamples.0) / stepSize
                    , sample.value )
            }
        }
        
        let grouppedByDate = Dictionary(grouping: samplesFromStart, by: {
            $0.0
        })
        
        let ranges = grouppedByDate.map { r in
            [
                r.key,
                r.value.min(by: { $0.1 > $1.1})!.1,
                r.value.max(by: { $0.1 > $1.1})!.1
            ]
        }.sorted(by: { $0[0] > $1[0] })
        
        return ranges
    }
    
    func get50th() -> [[Double]] {
        let stepSize: TimeInterval = 60*60
        let samplesFromStart = samples.flatMap { eventSamples in
            eventSamples.1.map { sample in
                (
                    sample.date.timeIntervalSince(eventSamples.0) / stepSize
                    , sample.value )
            }
        }
        
        let grouppedByDate = Dictionary(grouping: samplesFromStart, by: {
            $0.0
        })
        
       
        let ranges:[[Double]] = grouppedByDate.map { r in
            let sorted = r.value.map{ $0.1 }.sorted()
            let percentile25 = Int(0.25 * Double(r.value.count))
            let percentile75 = Int(0.75 * Double(r.value.count))
            return [
                r.key,
                sorted[percentile25],
                sorted[percentile75],
            ]
        }.sorted(by: { $0[0] > $1[0] })
        
        return ranges
    }
    
    func getCategories() -> [String] {
        return ["+00:00", "+01:00", "+02:00", "+03:00"]
    }
}

struct GlucoseStatisticsChart_Previews: PreviewProvider {
    static var previews: some View {
        
        let start = Date.now.addingTimeInterval(TimeInterval(3 * 60 * 60) * -1)
        let end = Date.now
        let debug = Debug()
        let samples = (1...5).map { _ in
            return (start, debug.getGlucoseSamples(
                start: start,
                end: end
            ))
        }
        return  VStack {
            GlucoseStatisticsChart(samples:samples)
        }
        .background(.black)
        .frame(height: 200)
    }
}

