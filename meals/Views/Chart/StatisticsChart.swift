//
//  GlucoseRangeChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct StatisticsChart: UIViewRepresentable {
    let title: String
    let colors: [String]
    let resolution: TimeInterval
    let range: TimeInterval
    var samples: [(Date, [MetricSample])]

    init(title: String, colors: [String], samples: [(Date, [MetricSample])], range: TimeInterval, resolution: TimeInterval) {
        self.title = title
        self.colors = colors
        self.samples = samples
        self.resolution = resolution
        self.range = range
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let chartView = uiView as? AAChartView {
            let aaChartModel = getModel()
            chartView.aa_drawChartWithChartModel(aaChartModel)
        }
    }

    func makeUIView(context: Context) -> some UIView {
        let aaChartView = AAChartView()
        aaChartView.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark
        ? UIColor.black
        : UIColor.white
        let aaChartModel = getModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        return aaChartView
    }

    func getModel() -> AAChartModel {
        let categories = getCategories()
        let statisticsBuckets = calculatePercentiles(eventSamples: samples, resolution: resolution)
        let percentiles25to75 = statisticsBuckets.map {
            [$0.index, $0.percentile25, $0.percentile75]
        }
        let minMaxs = statisticsBuckets.map {
            [$0.index, $0.min, $0.max]
        }
        let medians = statisticsBuckets.map {
            [$0.index, $0.median]
        }
        let backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark
        ? "black"
        : "white"
        let foregroundColor = AAStyle(color:
                                        UITraitCollection.current.userInterfaceStyle == .dark
                                      ? "white"
                                      : "black"
        )
        return AAChartModel()
            .backgroundColor(backgroundColor)
            .yAxisLabelsStyle(foregroundColor)
            .xAxisLabelsStyle(foregroundColor)
            .dataLabelsStyle(foregroundColor)
                .title(title)
                .xAxisTickInterval(2)
                .categories(categories)
                .colorsTheme(colors)
                .legendEnabled(false)
                .dataLabelsEnabled(false)
                .backgroundColor(backgroundColor)
                .series([
                    AASeriesElement()
                            .type(.line)
                            .name("median")
                            .lineWidth(0)
                            .marker(AAMarker().radius(3))
                            .data(medians)
                            .zIndex(2),
                    AASeriesElement()
                            .type(.areasplinerange)
                            .name("50%")
                            .data(percentiles25to75)
                            .marker(AAMarker().radius(0))
                            .zIndex(1),
                    AASeriesElement()
                            .type(.arearange)
                            .name("100%")
                            .lineWidth(5)
                            .marker(AAMarker().radius(0))
                            .data(minMaxs)
                            .zIndex(0)
                ])
    }

    func getCategories() -> [String] {
        stride(from: 0, through: range, by: resolution).map { category in
            DateUtils.formatTimeInterval(timeInterval: category)
        }
    }
}

struct StatisticsChart_Previews: PreviewProvider {
    static var previews: some View {
        let range = TimeInterval(3 * 60 * 60)
        let start = Date.now.addingTimeInterval(-range)
        let end = Date.now
        let debug = Debug()
        let samples = (1...5).map { _ in
            (start, debug.getInsulinSamples(
                    start: start,
                    end: end
            ))
        }
        return VStack {
            StatisticsChart(
                    title: "Insulin",
                    colors: ["#f00", "#800", "#500"],
                    samples: samples,
                    range: range, resolution: 15 * 60
            )
        }
                .background(.black)
                .frame(height: 200)
    }
}
