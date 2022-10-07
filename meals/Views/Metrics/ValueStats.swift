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
    var start:Date
    var end:Date
    var dateStepSizeMinutes:Double
    var dateAxisResolution:Int =  1
    
    var valueMin: Double
    var valueStepSize: Double
    var valueMax: Double
    var valueColor: (_: Double) -> Color
    var calculatePercentiles: Bool = false
    
    @State var selectedIdx: Int? = nil
    
    // Views
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
                    dateAxisGrid(size: geo.size)
                    
                    valueAxisLabels(size: geo.size, valueBuckets: valueBuckets)
                    valueAxisGrid(size: geo.size, valueBuckets: valueBuckets)
                    
                    // Capsules
                    capsules(valueBuckets: valueBuckets, width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .padding()
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
    
    func dateAxisLabels(size: CGSize) -> some View {
        let dateAxisValues = Array(getDateAxisValues().enumerated())
        let values = dateAxisValues
            .filter { offset, _ in
                let edgeAxis = offset == 0 || offset == dateAxisValues.count-1
                let middleAxis = offset % dateAxisResolution == 0
                return edgeAxis || middleAxis
            }
        return ForEach(values, id: \.element.self){ idx, axisValue in
            Text(formatTime(interval: TimeInterval(axisValue*60)))
                .position(
                    x: minutesToPixels(
                        minutes: Double(axisValue),
                        width: size.width
                    ),
                    y: size.height
                )
        }
    }
    
    func valueAxisLabels(size: CGSize, valueBuckets: [ValueBucket]) -> some View {
        let valueSteps = valueSteps(valueBuckets: valueBuckets)
        return ForEach(valueSteps, id: \.self){ value in
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
        let max = getTrueMax(valueBuckets: valueBuckets)
        let min:Double = getTrueMin(buckets: valueBuckets)
        let bucketCount = (max-min) / valueStepSize

        return Array(stride(
            from: min,
            through: max,
            by: valueStepSize
        ))
    }
    

    func capsules(valueBuckets: [ValueBucket], width: CGFloat, height: CGFloat) -> some View {
        let e = Array(valueBuckets.enumerated())
        return ForEach(e, id: \.offset) { index, valueBucket  in
            let valueRange = valuePixelRange(
                value: valueBucket.max - valueBucket.min,
                height: height,
                buckets: valueBuckets
            )
            let capsuleWidth = minutesToPixels(
                minutes: Double(dateStepSizeMinutes),
                width: width
            ) * 0.2
            let minutePixels = minutesToPixels(
                minutes: Double(index) * dateStepSizeMinutes,
                width: width
            )
            let valuePixels = valueToPixels(
                value: valueBucket.max,
                height: height,
                buckets: valueBuckets
            )
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
    
    var noData: some View {
        return VStack(alignment: .center) {
            Spacer()
            Image(systemName: "tray.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary.opacity(0.5))
                .font(.system(size: 30, weight: .ultraLight))
                .frame(width: 80)
            
            HStack(alignment: .center){
                Spacer()
                Text("No data")
                    .font(.title)
                Spacer()
            }
            Spacer()
        }
        
    }
    
    // Helpers
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
        return Array(stride(
            from: 0,
            through:  Int(end.timeIntervalSince1970-start.timeIntervalSince1970) / 60,
            by: Int(dateStepSizeMinutes)
        ))
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
        let scale = (width-offset) / CGFloat(end.timeIntervalSince(start) / 60)
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


struct ValueStats_Previews: PreviewProvider {
    static var previews: some View {
        let hours = 3
        let start = Date.now
        let end = start.addingTimeInterval(TimeInterval(hours)*60*60)
        let glucoseSamples = Debug().getGlucoseSamples(
            start: start,
            end: end
        )
        
        let insulinSamples = Debug().getInsulinSamples(
            start: start,
            end: end
        )
        
        return Group {
            VStack(alignment:.leading) {
                ValueStats(eventSamples: [0: (start, glucoseSamples)],
                           start: start,
                           end: end,
                           dateStepSizeMinutes: 15,
                           valueMin: 75 ,
                           valueStepSize: 25,
                           valueMax: 300,
                           valueColor: { _ in Color.green})
                .frame(height: 150)
            }
            VStack(alignment:.leading) {
                Text("Step size: 30")
                    .font(.title)
                    .padding()
                ValueStats(eventSamples: [0: (start, glucoseSamples)],
                           start: start,
                           end: end,
                           dateStepSizeMinutes: 30,
                           valueMin: 75 ,
                           valueStepSize: 25,
                           valueMax: 300,
                           valueColor: { _ in Color.green})
                .frame(height: 150)
            }
            VStack(alignment:.leading) {
                Text("Step size: 60")
                    .font(.title)
                    .padding()
                ValueStats(eventSamples: [0: (start, glucoseSamples)],
                           start: start,
                           end: end,
                           dateStepSizeMinutes: 60,
                           valueMin: 75 ,
                           valueStepSize: 25,
                           valueMax: 300,
                           valueColor: { _ in Color.green})
                .frame(height: 150)
            }
            VStack(alignment:.leading) {
                Text("Insulin samples")
                    .font(.title)
                    .padding()
                ValueStats(eventSamples: [0: (start, insulinSamples)],
                           start: start,
                           end: end,
                           dateStepSizeMinutes: 30,
                           valueMin: 0 ,
                           valueStepSize: 0.5,
                           valueMax: 3,
                           valueColor: { _ in Color.accentColor})
                .frame(height: 150)
            }
        }
        
    }
}

