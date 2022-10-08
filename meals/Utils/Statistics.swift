//
// Created by aclowkey on 08/10/2022.
//

import Foundation

// Take a list of samples and their relative start date and an interval
// and calculate the percentile for each interval
func calculatePercentiles(relativeSamples: [(Date, [MetricSample])], interval: TimeInterval) -> [StatisticsBucket] {
    // Calculate the samples offset from their start date
    let offsetFromDate: [(Double, Double)] = relativeSamples.flatMap { date, samples in
        samples.map { sample in
            (
                    sample.date.timeIntervalSince(date) / interval,
                    sample.value
            )
        }
    }

    // Group the samples by their offset
    let groupedByOffset = Dictionary(grouping: offsetFromDate) {
        $0.0
    }

    // Calculate the statistics
    return groupedByOffset.map { offset, samples in
        let sorted = samples.map {
                    $0.1
                }
                .sorted()
        let min = sorted.first!
        let max = sorted.last!
        let percentile25 = sorted[Int(0.25 * Double(samples.count))]
        let percentile75 = sorted[Int(0.75 * Double(samples.count))]
        // 1,2,3,4,5
        let middlePoint = Int(ceil(Double(sorted.count / 2)))
        let median = sorted.count % 2 == 0
                ? (sorted[middlePoint] + sorted[middlePoint - 1])
                : sorted[middlePoint]
        return StatisticsBucket(
                index: offset,
                min: min,
                max: max,
                percentile25: percentile25,
                percentile75: percentile75,
                median: median
        )
    }.sorted(by: { $0.index < $1.index})

}


struct StatisticsBucket {
    var index: Double
    var min: Double
    var max: Double
    var percentile25: Double
    var percentile75: Double
    var median: Double
}