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
    let backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark
    ? "black"
    : "white"
    let foregroundColor = AAStyle(color:
                                    UITraitCollection.current.userInterfaceStyle == .dark
                                  ? "white"
                                  : "black"
    )
    
    init(start: Date, end: Date, samples: [MetricSample]){
        self.start = start
        self.end = end
        self.samples = samples
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let chartView = uiView as? AAChartView {
            let aaChartModel = getModel()
            chartView.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark
            ? UIColor.black
            : UIColor.white
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
            .backgroundColor(backgroundColor)
            .yAxisLabelsStyle(foregroundColor)
            .xAxisLabelsStyle(foregroundColor)
            .dataLabelsStyle(foregroundColor)
            .chartType(.area)
            .animationType(.easeInSine)
            .categories(categories)
            .colorsTheme(["#fe9711"])
            .markerRadius(0)
            .xAxisTickInterval(5)
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


