//
//  GlucoseRangeChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct InsulinStatisticsChart: UIViewRepresentable {
    let stepSize: TimeInterval = 15 * 60
    var samples: [(Date, [MetricSample])]

    init(samples: [(Date, [MetricSample])]) {
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
        let statisticsBuckets = getStatistics()
        let percentiles25to75 = statisticsBuckets.map { [$0.index, $0.percentile25, $0.percentile75] }
        let minMaxs = statisticsBuckets.map { [$0.index, $0.min, $0.max] }
        let medians = statisticsBuckets.map { [$0.index, $0.median] }
        return AAChartModel()
                .title("Insulin")
                .categories(categories)
                .colorsTheme(["#ffa700","#fccb6f", "#fae0af"])
                .legendEnabled(false)
                .series([
                    AASeriesElement()
                            .type(.spline)
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

    func getStatistics() -> [StatisticsBucket] {
        let range = 3 * 60 * TimeInterval(60) // 3 hours hard coded for now
        let iobNormalized = samples.map { date, samples in
            (
                    date,
                    calculateIOB(insulinDelivery: samples ,
                            start: date,
                            end: date.addingTimeInterval(range)
                    ))
        }
        return calculatePercentiles(relativeSamples: iobNormalized, interval: stepSize)
    }

    func getCategories() -> [String] {
        // TODO: Calculate this too
        return ["+00:00", "+01:00", "+02:00", "+03:00"]
    }
}

struct InsulinStatisticsChart_Previews: PreviewProvider {
    static var previews: some View {

        let start = Date.now.addingTimeInterval(TimeInterval(3 * 60 * 60) * -1)
        let end = Date.now
        let debug = Debug()
        let samples = (1...5).map { _ in
            return (start, debug.getInsulinSamples(
                    start: start,
                    end: end
            ))
        }
        return VStack {
            GlucoseStatisticsChart(samples: samples)
        }
                .background(.black)
                .frame(height: 200)
    }
}

