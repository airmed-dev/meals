//
//  GlucoseChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct GlucoseChart: UIViewRepresentable {
    let start: Date
    let end: Date
    let samples: [MetricSample]
    
    init(start: Date, end: Date, samples: [MetricSample]){
        self.start = start
        self.end = end
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
    
    func getModel() -> AAChartModel{
        let data = getData()
        let categories = getCategories()
        return AAChartModel()
            .chartType(.line)
            .animationType(.easeInSine)
            .categories(categories)
            .colorsTheme(["#11a7fe"])
            .markerRadius(3)
            .xAxisTickInterval(5)
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .tooltipEnabled(false)
            .series([
                AASeriesElement()
                    .lineWidth(0)
                    .name("Glucose")
                    .data(data),
            ])
    }
    
    func getData() -> [Double] {
        samples.map { $0.value }
    }
    
    func getCategories() -> [String] {
        samples.map { formatTime(date: $0.date)}
    }
    
    func formatTime(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
}

