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
    
    @State var samples: [MetricSample] = []
    @State var event: Event
    @State var start: Date
    @State var end: Date
    
    @State var debug = false
    @State var error: Error? = nil
    @State var hours = 3
    
    var width: CGFloat = 5
    let glucoseMin = 40
    let glucoseMax = 500
    
    var body: some View {
        VStack {
            Text("Samples: \(samples.count)")
            Text("Authorized: \( isAuthorized ? "Authorized" : "Not authorized" )")
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            GeometryReader { geomtry in
                let maxWidth = geomtry.size.width*1
                Path { path  in
                    let normalizedGraph = normalizeGraph(
                        width: Int(maxWidth),
                        height: Int(geomtry.size.height)
                    )
                    normalizedGraph.forEach { sample in
                        path.move(to: sample)
                        path.addArc(
                            center: sample,
                            radius: 3,
                            startAngle: Angle(), endAngle: Angle(),
                            clockwise: false
                        )
                    }
                    
                }
                .strokedPath(StrokeStyle.init(lineWidth: width, lineCap: .round ))
                .foregroundColor(.blue)
                
                let glucoseRange = CGFloat(glucoseMax-glucoseMin)
                let logBar = (geomtry.size.height / glucoseRange)
                let yLow = geomtry.size.height - (logBar*70)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yLow))
                    path.addLine(to: CGPoint(x: geomtry.size.width, y: yLow ))
                }
                .strokedPath(StrokeStyle.init(lineWidth: width/5))
                .foregroundColor(.gray)
                
                let yHigh = geomtry.size.height - (logBar*180)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yHigh))
                    path.addLine(to: CGPoint(x: geomtry.size.width, y: yHigh ))
                }
                .strokedPath(StrokeStyle.init(lineWidth: width/5))
                
                .foregroundColor(.red)
                Text("180")
                    .font(.subheadline)
                    .position(x: 0, y: yHigh)
                Text("70")
                   .font(.subheadline)
                   .position(x: 0, y: yLow)
                
                // Time slices
                HStack{
                    Text(event.date.ISO8601Format())
                        .font(.subheadline)
                        .position(x: 50, y: geomtry.size.height)
                    Spacer()
                    Text(event.date.advanced(by: 60*60*TimeInterval(hours)).ISO8601Format())
                        .font(.subheadline)
                        .position(x: geomtry.size.width-30, y: geomtry.size.height)
                }
                .padding()

            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 15, green: 32, blue: 39),
                        Color(red: 15, green: 32, blue: 39),
                        Color(red: 44, green: 83, blue: 100),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
           
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
                Text("Time period: \(hours) hours")
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
                    
                loadSamples()
            }
        }
        .onChange(of: self.hours) { _ in
            loadSamples()
        }
    }
    
    func loadSamples(){
        let hoursInSeconds = 60*60*TimeInterval(hours)
        
        HealthKitUtils().getSamples(event: event,hours: hoursInSeconds, debug: debug) { result in
            switch result {
            case .success(let samples):
                self.samples = samples
                self.error = nil
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func normalizeGraph(width: Int, height: Int) -> [CGPoint] {
        let xOffset = 0
        let yOffset = 0
        
        return samples.enumerated().map { sampleIndex, samplePoint in
            let xScale = width / (samples.count)
            let yScale = height / (glucoseMax-glucoseMin)
            
            let y = height - Int(samplePoint.value) * yScale
            return CGPoint(x: xOffset + sampleIndex*xScale, y: y)
        }
    }
        
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void ){
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false,  HealthkitError.notAvailableOnDevice)
            return
        }
            
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let glucose = HKSampleType.quantityType(forIdentifier: .bloodGlucose) else {
            completion(false, HealthkitError.dataTypeNotAvailable)
            return
        }
        
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, glucose]
        
        HKHealthStore().requestAuthorization(toShare: [], read: healthKitTypesToRead) { (success, error) in
           completion(success, error)
        }
        
    }
}


struct MetricGraph_Previews: PreviewProvider {
    static var previews: some View {
        MetricGraph(
            samples: [
                MetricSample(Date.init(timeIntervalSinceNow: 480), 70),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
            ],
            event: Event(meal_id: UUID()),
            start: Date.init(timeIntervalSinceNow: 90),
            end: Date.now,
            debug: true
        )
        .frame(width: 300, height: 300)
        .border(.black)
    }
}
