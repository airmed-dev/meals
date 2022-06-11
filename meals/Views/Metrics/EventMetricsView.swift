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
    .Insulin: (0,5),
    .Glucose: (40, 400)
]

struct MetricGraph: View {
    @State var isAuthorized = false
    
    var event: Event
    var dataType: DataType
    
    @State var samples: [MetricSample] = []
    @State var debug = false
    @State var error: Error? = nil
    @State var hours = 3
    
    var body: some View {
        VStack {
            if debug {
                Text("Authorized: \( isAuthorized ? "Authorized" : "Not authorized" )")
                Text("Glucose Samples: \( samples.count )")
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            Graph(samples: samples,
                  dateRange:(
                    event.date,
                    event.date.advanced(by: TimeInterval(hours * 60 * 60))
                  ),
                  valueRange: ranges[dataType]!,
                  colorFunction: { point in
                    if dataType == .Glucose {
                        if point.value > 180 || point.value < 70 {
                            return Color.red
                        }
                    }
                    return Color.white
                  }
            )
        }
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button {
                        hours = 3
                    } label: {
                        Text("3 hours")
                    }
                    Button {
                        hours = 6
                    } label: {
                        Text("6 hours")
                    }
                } label: {
                    Text("\(hours) hours")
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
                print("Authorized succesfully")
                isAuthorized=true
                
                loadSamples(for: self.event)
            }
        }
        .onChange(of: self.event) { newEvent in
            loadSamples(for: newEvent)
        }
    }
    
    
    func loadSamples(for event:Event){
        let hoursInSeconds = 60*60*TimeInterval(hours)
        switch self.dataType {
        case .Glucose:
            HealthKitUtils().getGlucoseSamples(event: event, hours: hoursInSeconds) { result in
                switch result {
                case .success(let samples):
                    self.samples = samples
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
            }
        case .Insulin:
            HealthKitUtils().getInsulinSamples(event: event, hours: hoursInSeconds) { result in
                switch result {
                case .success(let samples):
                    self.samples = samples
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
            }
        }
        
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
}


struct MetricGraph_Previews: PreviewProvider {
    static var previews: some View {
        MetricGraph(
            event: Event(meal_id: 1),
            dataType: .Glucose,
            samples: [
                MetricSample(Date.init(timeIntervalSinceNow: 480), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 150),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 200),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
            ],
            debug: true
        )
        .frame(width: 300, height: 300)
    }
}
