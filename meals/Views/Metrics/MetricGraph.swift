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
    
    @State var glucoseSamples: [MetricSample] = []
    @State var insulinSamples: [MetricSample] = []
    @State var event: Event
    @State var start: Date
    @State var end: Date
    
    @State var debug = false
    @State var error: Error? = nil
    @State var hours = 3
    @State var fetchInsulin = false
    
    var width: CGFloat = 7
    let glucoseMin = 40
    let glucoseMax = 400
    
    let rangeMin: Double = 70
    let rangeMax: Double = 180
    
    let textPadding:CGFloat = -15
    
    var body: some View {
        VStack {
            if debug {
                Text("Authorized: \( isAuthorized ? "Authorized" : "Not authorized" )")
                Text("Glucose Samples: \( glucoseSamples.count )")
            }
            if let error = error {
                Text("ERROR: \(error.localizedDescription)")
            }
            
            GeometryReader { geomtry in
                // Glucose values
                let normalizedGraph = normalizeGraph(
                    samples: glucoseSamples,
                    width: geomtry.size.width, height: geomtry.size.height,
                    dateMin: start, dateMax: end,
                    valueMin: Double(glucoseMin), valueMax: Double(glucoseMax)
                )
                ForEach(normalizedGraph, id: \.id) { sample in
                    let color = sample.value > rangeMin && sample.value < rangeMax
                    ? Color.green
                    : Color.red
                    Circle()
                        .fill(color)
                        .frame(width: width, height: width)
                        .position(x: sample.x, y: sample.y)
                }

                // Range axises
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
                
                let yVeryHigh = geomtry.size.height - (logBar*250)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yVeryHigh))
                    path.addLine(to: CGPoint(x: geomtry.size.width, y: yVeryHigh ))
                }
                .strokedPath(StrokeStyle.init(lineWidth: width/5))
                .foregroundColor(.red)
                 
                Text("250")
                    .font(.subheadline)
                    .position(x: textPadding, y: yVeryHigh)
                Text("180")
                    .font(.subheadline)
                    .position(x: textPadding, y: yHigh)
                Text("70")
                   .font(.subheadline)
                   .position(x: textPadding, y: yLow)
                
                // Time Axi
                HStack{
                    Text(formatAsTime(date: event.date))
                        .font(.subheadline)
                        .position(x: 50, y: geomtry.size.height-textPadding)
                    Spacer()
                    Text(
                        formatAsTime(date:
                            event.date.advanced(by: 60*60*TimeInterval(hours))
                         )
                    )
                    .font(.subheadline)
                    .position(x: geomtry.size.width-200, y: geomtry.size.height-textPadding)
                }
                .frame(maxWidth: .infinity)
            }
                        
            if fetchInsulin {
                Divider()
                Text("Insulin")
                    .padding()
                GeometryReader { geomtry in
                    // Glucose values
                    let normalizedGraph = normalizeGraph(
                        samples: insulinSamples,
                        width: geomtry.size.width, height: geomtry.size.height,
                        dateMin: start, dateMax: end,
                        valueMin: 0, valueMax: 5
                    )
                    ForEach(normalizedGraph, id: \.id) { sample in
                        let color = sample.value > rangeMin && sample.value < rangeMax
                        ? Color.green
                        : Color.red
                        Circle()
                            .fill(color)
                            .frame(width: width, height: width)
                            .position(x: sample.x, y: sample.y)
                    }

                    // Range axises
                    let insulinRange = CGFloat(50)
                    let logBar = (geomtry.size.height / insulinRange)
                    
                    Text("1")
                        .font(.subheadline)
                        .foregroundColor(Color.primary)
                        .position(x: textPadding, y: logBar * 0.5)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: logBar*0.5))
                        path.addLine(to: CGPoint(x: geomtry.size.width, y: logBar*0.5 ))
                    }
                    .strokedPath(StrokeStyle.init(lineWidth: 1))
                    
                    // Time Axi
                    HStack{
                        Text(formatAsTime(date: event.date))
                            .font(.subheadline)
                            .position(x: 50, y: geomtry.size.height-textPadding)
                        Spacer()
                        Text(
                            formatAsTime(date:
                                event.date.advanced(by: 60*60*TimeInterval(hours))
                             )
                        )
                        .font(.subheadline)
                        .position(x: geomtry.size.width-200, y: geomtry.size.height-textPadding)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(Color(uiColor: UIColor.systemBackground))

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
                    
                loadSamples()
            }
        }
        .onChange(of: self.hours) { _ in
            loadSamples()
        }
    }
    
    func formatAsTime(date:Date) -> String {
        let hourlyFormatter = DateFormatter()
        hourlyFormatter.dateFormat = "HH:mm"
        return hourlyFormatter.string(from: date)
    }
    
    func loadSamples(){
        let hoursInSeconds = 60*60*TimeInterval(hours)
        self.end = event.date.advanced(by: hoursInSeconds)
        
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
    
    func normalizeGraph(samples: [MetricSample],
                        width: Double, height: Double,
                        dateMin: Date, dateMax: Date,
                        valueMin: Double, valueMax: Double) -> [GraphPoint] {
        let xScale = width / (dateMax.timeIntervalSince(dateMin) * 60.0)
        let yScale = height / Double(valueMax-valueMin)
        
        return samples.enumerated().map { _, samplePoint in
            
            let y = height - samplePoint.value * yScale
            let x = (samplePoint.date.timeIntervalSince(dateMin) * 60.0)
                    * xScale
            return GraphPoint(
                x: x,
                y: y,
                value: samplePoint.value,
                id: "\(x)"
            )
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


struct GraphPoint: Identifiable, Equatable {
    let x: Double
    let y: Double
    let value: Double
    let id: String
}

struct MetricGraph_Previews: PreviewProvider {
    static var previews: some View {
        MetricGraph(
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
            event: Event(meal_id: 1, id: 1, date: Date()),
            start: Date.init(timeIntervalSinceNow: 90),
            end: Date.now,
            debug: true
        )
        .frame(width: 300, height: 300)
    }
}
