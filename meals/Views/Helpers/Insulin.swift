//
//  Insulin.swift
//  meals
//
//  Credits: This code is mostly copied from LoopKit
//  I wasn't able to import it properly so, I just copied the functionality from
//

import Foundation


import Foundation

func calculateIOB(insulinDelivery: [MetricSample], start: Date, end: Date) -> [MetricSample] {
    if insulinDelivery.isEmpty {
        return []
    }
    // Calculate iob for every 5 minute sample between start and end
    // Prepare insulin model. right now just for humalog
    // values are copied from LoopKit
    let activeDuration: TimeInterval = 360 * 60
    let peakActivityTime: TimeInterval = 75 * 60
    let delay: TimeInterval = 10 * 60
    
    let insulinModel =
    ExponentialInsulinModel(
        actionDuration: activeDuration,
        peakActivityTime: peakActivityTime,
        delay: delay
    )
    
    // Calculate cummulative insulin on board
    // Calculate this by iterating over every 5 minute point in the result range
    // for each point, find all the insulin delivery that are relevant
    // calculate for each the active percentage and sum them
    let samplePeriod: TimeInterval = 5 * 60
    var currentPoint: Date = start
    var iobSamples: [MetricSample] = []
    while currentPoint <= end {
        // Find all insulin delivery that is relevent
        // We could probably optimize it by using time window function
        // Also the insulin delivery is sorted by date, so it could also be optimized
        let relevantInsulinDosage = insulinDelivery.filter { dose in
            return dose.date < currentPoint &&
            dose.date.advanced(by: activeDuration) >= currentPoint
        }
        
        // Calculate the active percentage of each sample
        let dosagesPercentages = relevantInsulinDosage.map { dose in
            dose.value *  insulinModel.percentEffectRemaining(at: dose.date.distance(to: currentPoint))
        }
        
        // Sum the samples
        let iob = dosagesPercentages.reduce(0, +)
        iobSamples.append(MetricSample(currentPoint, iob))
        
        // Proceed to the next point
        currentPoint = currentPoint.advanced(by: samplePeriod)
    }
    
    return iobSamples
}


public struct ExponentialInsulinModel {
    public let actionDuration: TimeInterval
    public let peakActivityTime: TimeInterval
    public let delay: TimeInterval
    
    // Precomputed terms
    fileprivate let τ: Double
    fileprivate let a: Double
    fileprivate let S: Double
    
    /// Configures a new exponential insulin model
    ///
    /// - Parameters:
    ///   - actionDuration: The total duration of insulin activity, excluding delay
    ///   - peakActivityTime: The time of the peak of insulin activity from dose.
    ///   - delay: The time to delay the dose effect
    public init(actionDuration: TimeInterval, peakActivityTime: TimeInterval, delay: TimeInterval = 600) {
        self.actionDuration = actionDuration
        self.peakActivityTime = peakActivityTime
        self.delay = delay
        
        self.τ = peakActivityTime * (1 - peakActivityTime / actionDuration) / (1 - 2 * peakActivityTime / actionDuration)
        self.a = 2 * τ / actionDuration
        self.S = 1 / (1 - a + (1 + a) * exp(-actionDuration / τ))
    }
}

extension ExponentialInsulinModel {
    public var effectDuration: TimeInterval {
        return self.actionDuration + self.delay
    }
    
    /// Returns the percentage of total insulin effect remaining at a specified interval after delivery;
    /// also known as Insulin On Board (IOB).
    ///
    /// This is a configurable exponential model as described here: https://github.com/LoopKit/Loop/issues/388#issuecomment-317938473
    /// Allows us to specify time of peak activity, as well as duration, and provides activity and IOB decay functions
    /// Many thanks to Dragan Maksimovic (@dm61) for creating such a flexible way of adjusting an insulin curve
    /// for use in closed loop systems.
    ///
    /// - Parameter time: The interval after insulin delivery
    /// - Returns: The percentage of total insulin effect remaining
    
    public func percentEffectRemaining(at time: TimeInterval) -> Double {
        let timeAfterDelay = time - delay
        switch timeAfterDelay {
        case let t where t <= 0:
            return 1
        case let t where t >= actionDuration:
            return 0
        default:
            let t = timeAfterDelay
            return 1 - S * (1 - a) *
            ((pow(t, 2) / (τ * actionDuration * (1 - a)) - t / τ - 1) * exp(-t / τ) + 1)
        }
    }
}

extension ExponentialInsulinModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "ExponentialInsulinModel(actionDuration: \(actionDuration), peakActivityTime: \(peakActivityTime), delay: \(delay)"
    }
}
