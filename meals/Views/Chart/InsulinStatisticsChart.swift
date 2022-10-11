//
//  GlucoseRangeChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct InsulinStatisticsChart: View {
    let colors = ["#ffa700","#fccb6f", "#fae0af"]
    let range: TimeInterval
    let resolution: TimeInterval
    var samples: [(Date, [MetricSample])]

    var body: some View {
       StatisticsChart(
               title: "Insulin",
               colors: colors,
               samples: samples,
               range: range,
               resolution: resolution)
    }

}

struct InsulinStatisticsChart_Previews: PreviewProvider {
    static var previews: some View {
        let range = TimeInterval(3 * 60 * 60)
        let resolution = TimeInterval(15 * 60)
        let start = Date.now.addingTimeInterval( -range )
        let end = Date.now
        let debug = Debug()
        let samples = (1...5).map { _ in
            (start, debug.getInsulinSamples(
                    start: start,
                    end: end
            ))
        }
        return VStack {
            InsulinStatisticsChart(range: range, resolution: resolution, samples: samples)
        }
                .background(.black)
                .frame(height: 200)
    }
}
