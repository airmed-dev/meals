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

    let colorScheme: ColorScheme
    
    init(start: Date, end: Date, samples: [MetricSample], colorScheme: ColorScheme){
        self.start = start
        self.end = end
        self.samples = samples
        self.colorScheme = colorScheme
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let chartView = uiView as? AAChartView {
            let aaChartModel = getModel()
            chartView.aa_drawChartWithChartModel(aaChartModel)
        }
    }
    
    func makeUIView(context: Context) -> some UIView {
        let aaChartModel = getModel()
        let aaChartView = AAChartView()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        return aaChartView
        
    }
    
    func getModel() -> AAChartModel{
        let data = getData()
        let categories = getCategories()
        let backgroundColor: String = Theme.backgroundColor(scheme: colorScheme).toHex()
        let foregroundColor: String = Theme.foregroundColor(scheme: colorScheme).toHex()
        let foregroundStyle = AAStyle(color: foregroundColor)
        return AAChartModel()
            .backgroundColor(backgroundColor)
            .yAxisLabelsStyle(foregroundStyle)
            .xAxisLabelsStyle(foregroundStyle)
            .dataLabelsStyle(foregroundStyle)
            .chartType(.line)
            .animationType(.easeInSine)
            .categories(categories)
            .colorsTheme(["#11a7fe"])
            .markerRadius(3)
            .xAxisTickInterval(5)
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .series([
                AASeriesElement()
                    .lineWidth(0)
                    .name("Glucose")
                    .data(data),
            ])
    }
    
    func getData() -> [Double] {
        // TODO: It should behave differently for mmol/L
        samples.map { rounded($0.value, toPlaces: 0)}
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

