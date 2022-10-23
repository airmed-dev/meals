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
        let pointCount = samples.map{$1.count}.reduce(0, +)
        if pointCount > 0 {
            StatisticsChart(
                    title: "Glucose",
                    colors: colors,
                    samples: samples,
                    range: range,
                    resolution: resolution)
        } else {
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Image(systemName: "tray.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary.opacity(0.5))
                            .font(.system(size: 30, weight: .ultraLight))
                            .frame(width: 50)
                        
                        Text("No data")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
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
