//
//  SimpleGlucose.swift
//  meals
//
//  Created by aclowkey on 02/07/2022.
//

import SwiftUI

struct ValueBucket {
    var index: Int
    var min: Double
    var max: Double
}

struct ValueStats: View {
    // Event samples contains data about events
    // the data is: EventID -> (Event Start, Event Samples)
    // it used to aggregate by the time differnce between the sample, the event start
    // thus giving a relative aggregating to the meal time
    var eventSamples: [Int: (Date, [MetricSample])]
    var hoursAhead: Int
    var dateAxisEvery = 2
    var valueAxisEvery = 2
    var dateStepSizeMinutes:Double
    
    var valueMin: Double
    var valueStepSize: Double
    var valueMax: Double
    var valueColor: (_: Double) -> Color
    var calculatePercentiles: Bool = false
    
    @State var selectedIdx: Int? = nil
    
    func dateAxisLabels(size: CGSize) -> some View {
        let values = Array ( getDateAxisValues().enumerated().filter { $0.offset % dateAxisEvery == 0} )
        return ForEach(values, id: \.element.self){ idx, axisValue in
            Text(formatTime(interval: TimeInterval(axisValue*60)))
                .position(
                    x: minutesToPixels(
                        minutes: Double(idx)*dateStepSizeMinutes,
                        width: size.width
                    ),
                    y: size.height
                )
        }
    }
    
    func valueAxisLabels(size: CGSize, valueBuckets: [ValueBucket], every: Int = 2) -> some View {
        let valueSteps = valueSteps(valueBuckets: valueBuckets)
        let values = Array(valueSteps.enumerated().compactMap { index, value in index % every == 0 ? value : nil})
        return ForEach(values, id: \.self){ value in
            Text(String(value))
                .position(
                    x: 20,
                    y: valueToPixels(value: value, height: size.height, buckets: valueBuckets)
                )
        }
    }
    
    func valueAxisGrid(size: CGSize, valueBuckets: [ValueBucket]) -> some View {
        ForEach(valueSteps(valueBuckets:  valueBuckets), id: \.self){ axisValue in
            Path { line in
                let valuePixels = valueToPixels(
                    value: axisValue, height:size.height, buckets: valueBuckets)
                line.move(to: CGPoint(x: CGFloat(40), y: valuePixels))
                line.addLine(to: CGPoint(x: size.width, y: valuePixels))
            }
            .strokedPath(StrokeStyle.init(lineWidth: 2))
            .foregroundColor(.black.opacity(0.1))
        }
    }
    
    func valueSteps(valueBuckets: [ValueBucket]) -> [Double]{
        return Array(stride(from: getTrueMin(buckets: valueBuckets), to: getTrueMax(valueBuckets: valueBuckets), by: valueStepSize))
    }
    
    func dateAxisGrid(size: CGSize) -> some View {
        ForEach(Array(getDateAxisValues().enumerated()), id: \.element.self){ idx, _ in
            Path { line in
                let minutePixels = minutesToPixels(
                    minutes: Double(idx) * dateStepSizeMinutes,
                    width: size.width
                )
                line.move(to: CGPoint(x: minutePixels, y: 0))
                line.addLine(to: CGPoint(x: minutePixels, y: size.height))
            }
            .strokedPath(StrokeStyle.init(lineWidth: 2))
            .foregroundColor(.black.opacity(0.1))
        }
    }
    
    
    var noData: some View {
        return VStack(alignment: .center) {
                Spacer()
                Image(systemName: "tray.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary.opacity(0.5))
                    .font(.system(size: 30, weight: .ultraLight))
                    .frame(width: 80)
            
                Text("No data")
                    .font(.title)
            
                HStack(alignment: .center){
                    Spacer()
                    Text("Log an event")
                        .font(.body)
                    Spacer()
                }
                Spacer()
            }
        
    }
    
    
    var body: some View {
        let valueBuckets = aggregate(samples: eventSamples)
        
        VStack {
            // Glucose Axis
            GeometryReader { geo in
                if valueBuckets.count == 0 {
                    noData
                } else {
                    // Date axis and labels
                    dateAxisLabels(size: geo.size)
                        .animation(.spring())
                    dateAxisGrid(size: geo.size)
                        .animation(.spring())
                    
                    // Value axis and labels
                    valueAxisLabels(size: geo.size,  valueBuckets: valueBuckets, every: valueAxisEvery)
                        .animation(.spring())
                    valueAxisGrid(size: geo.size, valueBuckets: valueBuckets)
                        .animation(.spring())
                    
                    // Capsules
                    ForEach(Array(valueBuckets.enumerated()), id: \.offset) { index, valueBucket  in
                        let valueRange = valuePixelRange(value: valueBucket.max - valueBucket.min, height: geo.size.height, buckets: valueBuckets)
                        let capsuleWidth = minutesToPixels(minutes: Double(dateStepSizeMinutes), width: geo.size.width) * 0.2
                        let minutePixels = minutesToPixels(minutes: Double(index) * dateStepSizeMinutes, width: geo.size.width)
                        let valuePixels = valueToPixels(value: valueBucket.max, height: geo.size.height, buckets: valueBuckets)
                        let padding:CGFloat = 15
                        let centerPoint = valuePixels + valueRange / 2
                        Capsule()
                            .fill(valueRangeGradient(valueBucket: valueBucket))
                            .frame(
                                width: capsuleWidth,
                                height: valueRange )
                            .position(
                                x: minutePixels,
                                y: centerPoint
                            )
                            .onTapGesture {
                                selectedIdx = index
                            }
                            .onHover { over in
                                if over {
                                    selectedIdx = index
                                } else {
                                    selectedIdx = nil
                                }
                            }
                            .animation(.spring())
                        
                        
                        
                        // Range labels
                        if selectedIdx == index {
                            Text("\(valueBucket.max, specifier: "%.0f")")
                                .padding(5)
                                .background(valueColor(valueBucket.max).opacity(0.7))
                                .cornerRadius(10)
                                .position(x: minutePixels, y: valuePixels-padding)
                                .shadow(radius: 3)
                                .foregroundColor(.white)
                            
                            Text("\(valueBucket.min, specifier: "%.1f")")
                                .padding(5)
                                .background(valueColor(valueBucket.min).opacity(0.7))
                                .cornerRadius(10)
                                .position(x: minutePixels, y: valuePixels+valueRange+padding)
                                .shadow(radius: 3)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func aggregate(samples: [Int:(Date,[MetricSample])]) -> [ValueBucket] {
        // Map from [EventID : (EventDate, [Samples])
        // to (offset, samples)
        let sampleValues: [(Int, Double)] = samples.values.flatMap { entry -> [(Int, Double)] in
            
            let offsets = entry.1.map { sample in
                (
                    Int(sample.date.timeIntervalSince(entry.0) / (dateStepSizeMinutes*60)),
                    sample.value
                )
            }
            return offsets
        }
        
        let groupedByHour = Dictionary(grouping: sampleValues, by: { $0.0} )
        
        return groupedByHour.map { index, samples in
            let values = samples.map { $0.1 }
            let min = values.min()!
            let max = values.max()!
            return ValueBucket(index: index, min: min, max: max)
        }.sorted(by: { $0.index < $1.index})
        
    }
    
    
    func formatTime(interval: TimeInterval) -> String{
        if interval == 0 {
            return "0:00"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        return formatter.string(from: interval)!
    }
    
    func getDateAxisValues() -> [Int]{
        return Array(stride(from: 0, to: hoursAhead*60, by: Int(dateStepSizeMinutes)))
    }
    
    
    func valueToPixels(value: Double, height: CGFloat, buckets: [ValueBucket]) -> CGFloat {
        let offset:CGFloat = -0
        let fromMin = CGFloat(value-getTrueMin(buckets: buckets))
        let scale = (height*0.9) / CGFloat(getTrueMax(valueBuckets: buckets) - getTrueMin(buckets: buckets))
        return height*0.9 - fromMin * scale + offset
    }
    
    func valuePixelRange(value: Double, height: CGFloat, buckets: [ValueBucket]) -> CGFloat {
        let scale = height / CGFloat(getTrueMax(valueBuckets: buckets) - getTrueMin(buckets: buckets))
        return CGFloat(scale) * CGFloat(value)
    }
    
    func minutesToPixels(minutes: Double, width: CGFloat) -> CGFloat {
        let offset: CGFloat = width * 0.2
        let scale = (width-offset) / CGFloat(hoursAhead*60)
        return offset + CGFloat(minutes) * CGFloat(scale)
    }
    
    func getTrueMax(valueBuckets: [ValueBucket]) -> Double{
        // Return the max of max and the max of values
        let realValueMax = valueBuckets.map {$0.max}.max()
        guard realValueMax != nil else {
            return valueMax
        }
        let stepDifference = (round(realValueMax! / valueStepSize)+1)
        return stepDifference * valueStepSize
    }
    
    func getTrueMin(buckets: [ValueBucket]) -> Double {
        let trueMin = buckets.map {$0.min}.min()
        guard trueMin != nil else {
            return valueMin
        }
        let stepDifference = (round(trueMin! / valueStepSize)) - 1
        return stepDifference * valueStepSize
    }
    
    
    func valueRangeGradient(valueBucket: ValueBucket) -> LinearGradient{
        // 0 -> 70: Black to Red.
        // 70 -> 150 -> green
        // 150 -> 300 -> Red to black
        let firstColor: Color = valueColor(valueBucket.max)
        let secondColor: Color = valueColor(valueBucket.min)
        
        
        return LinearGradient(
            gradient: Gradient(colors: [firstColor, secondColor]),
            startPoint: .top,
            endPoint: .bottom)
    }
    
}

