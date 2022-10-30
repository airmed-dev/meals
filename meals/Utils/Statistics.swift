//
// Created by aclowkey on 08/10/2022.
//

import Foundation



// Take a list of samples and their relative start date and a resolution
// and calculate the percentile for each step
func calculatePercentiles(eventSamples: [(Date, [MetricSample])], resolution: TimeInterval) -> [StatisticsBucket] {
    let relativeSamples: [[RelativeMetricSample]] = eventSamples.map {
        calculateRelativeSamples(eventSamples: $0)
    }
    
    let roundedIntervalRelativeSamples:[RelativeMetricSample] = relativeSamples
        .map {
            roundToNearestInterval(samples: $0, resolution: resolution)
        }.flatMap {
            $0
        }
    
    // Group the samples by their offset
    let groupedByOffset = Dictionary(grouping: roundedIntervalRelativeSamples) {
        $0.offset
    }
    
    // Calculate the statistics
    return groupedByOffset.map { offset, samples in
        let sorted = samples
            .map { rounded($0.value, toPlaces: 2)}
            .sorted()
        let min = sorted.first!
        let max = sorted.last!
        let percentile25 = sorted[Int(0.25 * Double(samples.count))]
        let percentile75 = sorted[Int(0.75 * Double(samples.count))]
        let middlePoint = Int(ceil(Double(sorted.count / 2)))
        let median = sorted.count % 2 == 0
        ? (sorted[middlePoint] + sorted[middlePoint - 1]) / 2
        : sorted[middlePoint]
        
        return StatisticsBucket(
            index: offset / resolution,
            min: min,
            max: max,
            percentile25: percentile25,
            percentile75: percentile75,
            median: median
        )
    }.sorted(by: { $0.index < $1.index})
    
}

func calculateRelativeSamples(eventSamples: (Date, [MetricSample])) -> [RelativeMetricSample] {
    eventSamples.1.map {
        RelativeMetricSample(
            $0.date.timeIntervalSince(eventSamples.0),
            $0.value
        )
    }
}

func roundToNearestInterval(samples: [RelativeMetricSample], resolution: TimeInterval) -> [RelativeMetricSample] {
    samples.map {
        RelativeMetricSample(
            resolution * round($0.offset / resolution),
            $0.value
        )
    }
}

