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
        var stepSize:Double = 50
        let largestMinimum:Double = 50
        let smallestMaximum:Double = 150
        let yAxisMinimum: Double = floor(
            min(
                largestMinimum,
                data.min()!
            ) / stepSize
        ) * stepSize
        let yAxisMaximum = ceil(
            max(
                data.max()!,
                smallestMaximum
            ) / stepSize
        ) * stepSize
        
        let yRange = yAxisMaximum - yAxisMinimum
        let stepCount = yRange / stepSize
        if  stepCount > 4 &&
            stepCount.truncatingRemainder(dividingBy: 2) == 0 {
            stepSize *= 2
        }
        
        let ySteps = Array(
            stride(
                from: yAxisMinimum,
                through: yAxisMaximum,
                by: stepSize
            )
            .map {
                    rounded($0, toPlaces: 0)
                }
        )
        
        let categories = getCategories()
        let backgroundColor: String = Theme.backgroundColor(scheme: colorScheme).toHex()
        let foregroundColor: String = Theme.foregroundColor(scheme: colorScheme).toHex()
        let foregroundStyle = AAStyle(color: foregroundColor)
        return AAChartModel()
            .backgroundColor(backgroundColor)
            .yAxisTickPositions(ySteps)
            .animationDuration(300)
            .yAxisLabelsStyle(foregroundStyle)
            .xAxisLabelsStyle(foregroundStyle)
            .xAxisGridLineWidth(1)
            .dataLabelsStyle(foregroundStyle)
            .chartType(.line)
            .animationType(.easeInSine)
            .categories(categories)
            .colorsTheme(["#11a7fe"])
            .markerRadius(3)
            .xAxisTickInterval(5)
            .yAxisMin(50)
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .series([
                AASeriesElement()
                    .lineWidth(0)
                    .name("Glucose")
                    .zones([
                        AAZonesElement()
                            .value(70)
                            .color(Color.red.toHex()),
                        AAZonesElement().value(200).color(Color.green.toHex()),
                        AAZonesElement().value(999).color(Color.red.toHex()),
                    ])
                    .data(data),
            ])
    }
    
    func getData() -> [Double] {
        // TODO: It should behave differently for mmol/L
        samples.map { rounded($0.value, toPlaces: 0)}
    }
    
    func getCategories() -> [String] {
        samples.map { formatTime(
            date: roundDate($0.date)
        )}
    }
    
    func roundDate(_ date: Date) -> Date {
        let stepSize = TimeInterval(60) * 30
        let roundedSeconds = floor(date.timeIntervalSince1970 / stepSize) * stepSize
        return Date(timeIntervalSince1970: roundedSeconds)
    }
    
    func formatTime(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
}

