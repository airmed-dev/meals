//
//  GlucoseRangeChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

//
//  GlucoseRangeChart.swift
//  meals
//
//  Created by aclowkey on 07/10/2022.
//

import Foundation
import SwiftUI
import AAInfographics

struct GlucoseStatisticsChart: View {
    let colors = ["#009dff","#6fc7fc", "#ced8de"]
    let range: TimeInterval
    let resolution: TimeInterval
    var samples: [(Date, [MetricSample])]

    var body: some View {
        StatisticsChart(
                title: "Glucose",
                colors: colors,
                samples: samples,
                range: range,
                resolution: resolution)
    }

}

struct GlucoseStatisticsChart_Previews: PreviewProvider {
    static var previews: some View {
        let range = TimeInterval(3 * 60 * 60)
        let resolution = TimeInterval(15 * 60)
        let start = Date.now.addingTimeInterval( -range )
        let end = Date.now
        let debug = Debug()
        let samples = (1...5).map { _ in
            (start, debug.getGlucoseSamples(
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
