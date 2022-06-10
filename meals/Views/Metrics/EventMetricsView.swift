//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit


struct MetricGraph: View {
    @State var isAuthorized = false
    
    var event: Event
    var fetchInsulin = false
    @State var glucoseSamples: [MetricSample] = []
    @State var insulinSamples: [MetricSample] = []
    
    @State var debug = false
    @State var error: Error? = nil
    @State var hours = 3
    
    var body: some View {
        VStack {
            if debug {
                Text("Authorized: \( isAuthorized ? "Authorized" : "Not authorized" )")
                Text("Glucose Samples: \( glucoseSamples.count )")
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            Graph(samples: glucoseSamples,
                  start: event.date,
                  end: event.date.advanced(by: TimeInterval(hours * 60 * 60))
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
        
        HealthKitUtils().getGlucoseSamples(event: event, hours: hoursInSeconds) { result in
            switch result {
            case .success(let samples):
                self.glucoseSamples = samples
                self.error = nil
            case .failure(let error):
                self.error = error
            }
        }
        
        HealthKitUtils().getInsulinSamples(event: event, hours: hoursInSeconds) { result in
            switch result {
            case .success(let samples):
                self.insulinSamples = samples
                self.error = nil
            case .failure(let error):
                self.error = error
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
            glucoseSamples: [
                MetricSample(Date.init(timeIntervalSinceNow: 480), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 150),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 200),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
            ],
            insulinSamples: [
                MetricSample(Date.init(timeIntervalSinceNow: 480), 1),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 4.5),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 5),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 2.3),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 2.5),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 1)
            ],
            debug: true
        )
        .frame(width: 300, height: 300)
    }
}
