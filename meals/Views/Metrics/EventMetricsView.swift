//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit

enum DataType {
    case Insulin
    case Glucose
}

let ranges: [DataType: (Double, Double)] = [
    .Insulin: (0,10),
    .Glucose: (40, 400)
]

let glucoseGradientColors =  [
    Color(hex: 0x360033),
    Color(hex: 0x0b8793)]

let insulinGradient =  [
    Color(hex: 0x135058),
    Color(hex: 0xf1f2b5)
]

struct SamplesAndRange {
    var samples: [MetricSample] = []
    var start: Date
    var end: Date
}

struct MetricGraph: View {
    @State var sampleAndRange: SamplesAndRange = SamplesAndRange(
        samples: [],
        start: Date.now.advanced(by: -1 * threeHours),
        end: Date.now
    )
    @State var isAuthorized = false
    @State var debug = false
    @State var error: Error? = nil
    @State var loading = false
    
    var event: Event
    var dataType: DataType
    var hours: Int
    
    var body: some View {
        VStack {
            let computedSamples = getSamples()
            if debug {
                Text("Authorized: \( isAuthorized ? "Authorized" : "Not authorized" )")
                switch dataType {
                case .Insulin:
                    Text("Insulin Samples: \( computedSamples.count )")
                case .Glucose:
                    Text("Glucose Samples: \( computedSamples.count )")
                }
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }

            if loading {
               ProgressView()
            } else {
                switch dataType {
                    case .Insulin:
                        Text("no insulin support")
                    case .Glucose:
                        SimpleGlucose(samplesAndRange: sampleAndRange)}
            }
            
            if debug {
                List(computedSamples) { sample in
                    HStack {
                        Text(sample.date.formatted())
                        Text(String(sample.value))
                    }
                }
            }
        }
        .onAppear {
            authorizeHealthKit { authorized, error in
                guard authorized else {
                    let baseMessage = "HealthKit Authorization Failed"
                    
                    if let error = error {
                        print("\(baseMessage). Reason: \(error.localizedDescription)")
                    } else {
                        print(baseMessage)
                    }
                    
                    return
                }
                isAuthorized=true
                loadSamples()
            }
        }
        .onChange(of: event) { _ in
            loadSamples()
        }
        .onChange(of: hours) { _ in
            loadSamples()
        }
    }
    
    func getSamples() -> [MetricSample] {
        switch dataType {
        case .Glucose:
            return self.sampleAndRange.samples
        case .Insulin:
            return []
        }
        
    }
 
    
    func loadSamples(){
        if debug {
            return
        }
        let hoursInSeconds = 60*60*TimeInterval(hours)
        switch self.dataType {
        case .Glucose:
            Nightscout().getGlucoseSamples(event: event, hours: hoursInSeconds) { result in
                switch result {
                case .success(let samples):
                    self.sampleAndRange = SamplesAndRange(
                        samples: samples,
                        start: event.date,
                        end: event.date.advanced(by: hoursInSeconds)
                    )
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
                loading = false
            }
        case .Insulin:
            // We would like to fetch all insulin delivery which might be still
            // active
            let insulinActiveTime: TimeInterval = 3 * hoursInSeconds
            let start = event.date.advanced(by: -1 * insulinActiveTime)
            let end = event.date.advanced(by: insulinActiveTime)
            
            HealthKitUtils().getInsulinSamples(start: start, end: end) { result in
                switch result {
                case .success(let samples):
                    self.sampleAndRange = SamplesAndRange(
                        samples: samples,
                        start: event.date,
                        end: event.date.advanced(by: hoursInSeconds)
                    )
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
                loading = false
            }
        }
        
    }
    
    func calculateIOB(insulinDelivery: [MetricSample], start: Date, end: Date) -> [MetricSample] {
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
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void ){
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false,  HealthkitError.notAvailableOnDevice)
            return
        }
        
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let glucose = HKSampleType.quantityType(forIdentifier: .bloodGlucose),
            let insulin = HKSampleType.quantityType(forIdentifier: .insulinDelivery) else {
            
            completion(false, HealthkitError.dataTypeNotAvailable)
            return
        }
        
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, glucose, insulin]
        
        HKHealthStore().requestAuthorization(toShare: [], read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func glucoseColors(point: GraphPoint) -> Color {
        if dataType == .Glucose {
            if point.value > 180 || point.value < 70 {
                return Color.red
            }
        }
        return Color.white
    }
    
    func range(samples: [MetricSample], min: Double, max:Double) -> (Double, Double){
        if samples.count == 0 {
            return (min, max)
        }
        let samplesMin = round(samples.min(by: {$0.value < $1.value})!.value)
        let sampleMax = round(samples.max(by: {$0.value < $1.value})!.value)
        
        if samplesMin == sampleMax {
            return (min, max)
        }
        
        return (samplesMin, sampleMax)
    }
}



struct MetricGraph_Previews: PreviewProvider {
    static var insulinSamples = [
        MetricSample(Date.init(timeIntervalSinceNow: 0 * 60 * 60), 5),
        MetricSample(Date.init(timeIntervalSinceNow: 1 * 60 * 60), 2),
        MetricSample(Date.init(timeIntervalSinceNow: 2 * 60 * 60), 1)
    ]
    
    static var glucoseSamples = [
        MetricSample(Date.init(timeIntervalSinceNow: 0), 300),
        MetricSample(Date.init(timeIntervalSinceNow: 50 * 60), 200),
    ]
    static var previews: some View {
        Group {
            MetricGraph(
                sampleAndRange: SamplesAndRange(samples: glucoseSamples,
                                                start: Date.now.advanced(by: -1 * threeHours),
                                                end: Date.now
                                               ),
                debug: true,
                event: Event(meal_id: 1),
                dataType: .Glucose,
                hours: 3
            )
            .frame(width: 300, height: 300)
//            TODO: Insulinc
//            MetricGraph(
//                event: Event(meal_id: 1),
//                dataType: .Insulin,
//                samples: insulinSamples,
//                samplesAndRange: SamplesAndRange(samples: glucoseSamples, start: glucoseSamples[0]!.date!),
//                samplesAndRange: SamplesAndRange(samples: glucoseSamples,
//                                                 start: Date.now),
//                debug: true,
//                debug: true,
//                hours: 3
//            )
//            .frame(width: 300, height: 300)
        }
    }
}
