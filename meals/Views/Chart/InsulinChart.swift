//
//  InsulinChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct InsulinChart: UIViewRepresentable {
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
        let aaChartView = AAChartView()
        let aaChartModel = getModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        return aaChartView
        
    }
    
    func getModel() -> AAChartModel{
        let data = getData()
        let categories = getCategories()
        let backgroundColor: String = Theme.backgroundColor(scheme: colorScheme).toHex()
        let foregroundColor: String = Theme.foregroundColor(scheme: colorScheme).toHex()
        let foregroundStyle = AAStyle(color: foregroundColor)
        let max = ceil(data.max()!)
        var yAxisTickPositions = Array(stride(
            from: 0,
            through: max,
            by: 1
        ))
        if yAxisTickPositions.last != max {
            yAxisTickPositions.append(max)
        }
        return AAChartModel()
            .backgroundColor(backgroundColor)
            .yAxisLabelsStyle(foregroundStyle)
            .yAxisTickPositions(yAxisTickPositions)
            .xAxisLabelsStyle(foregroundStyle)
            .xAxisGridLineWidth(1)
            .xAxisTickInterval(5)
            .dataLabelsStyle(foregroundStyle)
            .chartType(.area)
            .animationType(.easeInSine)
            .categories(categories)
            .colorsTheme(["#fe9711"])
            .markerRadius(0)
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .series([
                AASeriesElement()
                    .name("Insulin")
                    .data(data),
            ])
    }
    
    func getData() -> [Double] {
        samples.map { rounded($0.value, toPlaces: 2) }
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


