//
//  SimpleGlucose.swift
//  meals
//
//  Created by aclowkey on 02/07/2022.
//

import SwiftUI


struct GlucoseStats: View {
    // Event samples contains data about events
    // the data is: EventID -> (Event Start, Event Samples)
// it used to aggregate by the time differnce between the sample, the event start
    // thus giving a relative aggregating to the meal time
    var eventSamples: [Int: (Date, [MetricSample])]
    var dateAxisEvery = 2
    
    var glucoseMin = 75
    var glucoseStepSize = 50
    var glucoseMax = 300
    
    var glucoseAxisValues: [Int] {
        Array(stride(from: glucoseMin, to:glucoseMax, by: glucoseStepSize))
    }
    
    @State var selectedIdx: Int? = nil
    
    func dateAxisLabels(size: CGSize) -> some View {
        let values = Array ( getDateAxisValues().enumerated().filter { $0.offset % dateAxisEvery == 0} )
        return ForEach(values, id: \.element.self){ idx, axisValue in
            Text(formatTime(interval: TimeInterval(axisValue*60)))
                .position(
                    x: minutesToPixels(
                        minutes: idx*getStepSizeMinutes(),
                        width: size.width
                    ),
                    y: size.height
                )
        }
    }
    
    func valueAxisLabels(size: CGSize, every: Int = 2) -> some View {
        let values = Array(glucoseAxisValues.enumerated().compactMap { index, value in index % every == 0 ? value : nil})
        return ForEach(values, id: \.self){ axisValue in
            Text(String(axisValue))
                .position(
                    x: 20,
                    y: glucoseToPixels(glucose: axisValue, height: size.height)
                )
        }
    }
    
    func valueAxisGrid(size: CGSize) -> some View {
        ForEach(glucoseAxisValues, id: \.self){ axisValue in
            Path { line in
                let glucosePixels = glucoseToPixels(
                    glucose: axisValue, height:size.height)
                line.move(to: CGPoint(x: CGFloat(40), y: glucosePixels))
                line.addLine(to: CGPoint(x: size.width, y: glucosePixels))
            }
            .strokedPath(StrokeStyle.init(lineWidth: 2))
            .foregroundColor(.black.opacity(0.1))
        }
    }
    
    func dateAxisGrid(size: CGSize) -> some View {
        ForEach(Array(getDateAxisValues().enumerated()), id: \.element.self){ idx, _ in
            Path { line in
                let minutePixels = minutesToPixels(
                    minutes: idx * getStepSizeMinutes(),
                    width: size.width
                )
                line.move(to: CGPoint(x: minutePixels, y: 0))
                line.addLine(to: CGPoint(x: minutePixels, y: size.height))
            }
            .strokedPath(StrokeStyle.init(lineWidth: 2))
            .foregroundColor(.black.opacity(0.1))
        }
    }
    
    
    
    var body: some View {
        let glucoseRanges = aggregate(samples: eventSamples)
        HStack {
            VStack {
                // Glucose Axis
                GeometryReader { geo in
                    if glucoseRanges.count == 0 {
                        Text("No data")
                    } else {
                        // Date axis and labels
                        dateAxisLabels(size: geo.size)
                        dateAxisGrid(size: geo.size)
                       
                        // Value axis and labels
                        valueAxisLabels(size: geo.size, every: 1)
                        valueAxisGrid(size: geo.size)

                        // Capsules
                        ForEach(Array(glucoseRanges.enumerated()), id: \.offset) { index, capsule  in
                            let glucoseDiff = glucoseDiffToPixels(glucose: Int(capsule.valueMax - capsule.valueMin), height: geo.size.height)
                            let capsuleWidth = geo.size.height / CGFloat(glucoseRanges.count) * 0.3
                            let minutePixels = minutesToPixels(minutes: index * 30, width: geo.size.width)
                            let glucosePixels = glucoseToPixels(glucose: Int(capsule.valueMax), height: geo.size.height)
                            let padding:CGFloat = 15
                            Capsule()
                                .fill(glucoseRangeGradient(capsule: capsule))
                                .frame(
                                    width: capsuleWidth,
                                    height: glucoseDiff )
                                .position(
                                    x: minutePixels,
                                    y: glucosePixels + glucoseDiff / 2
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
                        
                            
                            // Range labels
                            if selectedIdx == index {
                                Text(String(Int(capsule.valueMax)))
                                    .padding(3)
                                    .background(glucoseValueColor(value: capsule.valueMax).opacity(0.1))
                                    .cornerRadius(10)
                                    .position(x: minutePixels, y: glucosePixels-padding)
                            
                                Text(String(Int(capsule.valueMin)))
                                    .padding(3)
                                    .background(glucoseValueColor(value: capsule.valueMin).opacity(0.1))
                                    .cornerRadius(10)
                                    .position(x: minutePixels, y: glucosePixels+glucoseDiff+padding)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func aggregate(samples: [Int:(Date,[MetricSample])]) -> [GlucoseCapsule] {
        let hourInSeconds:Double = 30*60
        // Map from [EventID : (EventDate, [Samples])
        // to (offset, samples)
        let sampleValues: [(Int, Double)] = samples.values.flatMap { entry -> [(Int, Double)] in
            let offsets = entry.1.map { sample in
                (
                    Int(sample.date.timeIntervalSince(entry.0) / hourInSeconds),
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
            return GlucoseCapsule(valueMin: min, valueMax: max, index: index)
        }.sorted(by: { $0.index > $1.index})
        
    }
    
    func formatTime(interval: TimeInterval) -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        return formatter.string(from: interval)!
    }
    
    func getDateAxisValues() -> [Int]{
        return Array(stride(from: 0, to: getNumberOfHours()*60, by: getStepSizeMinutes()))
    }
    
    func getStepSizeMinutes() -> Int {
        return 30
    }
    
    func glucoseToPixels(glucose: Int, height: CGFloat) -> CGFloat {
        let offset:CGFloat = -40
        let fromMin = CGFloat(glucose-glucoseMin)
        let scale = (height*0.9) / CGFloat(glucoseMax - glucoseMin)
        return height*0.9 - fromMin * scale + offset
    }
    
    func glucoseDiffToPixels(glucose: Int, height: CGFloat) -> CGFloat {
        let scale = height / CGFloat(glucoseMax - glucoseMin)
        return CGFloat(scale) * CGFloat(glucose)
    }
    
    func minutesToPixels(minutes: Int, width: CGFloat) -> CGFloat {
        let offset: CGFloat = width * 0.2
        let scale = (width-offset) / CGFloat(getNumberOfHours()*60)
        return offset + CGFloat(minutes) * CGFloat(scale)
    }
    
    func getNumberOfHours() -> Int {
       return 3
    }
    
    func glucoseRangeGradient(capsule: GlucoseCapsule) -> LinearGradient{
        // 0 -> 70: Black to Red.
        // 70 -> 150 -> green
        // 150 -> 300 -> Red to black
        var firstColor: Color = glucoseValueColor(value: capsule.valueMin)
        var secondColor: Color = glucoseValueColor(value: capsule.valueMax)
        
        
        return LinearGradient(
            gradient: Gradient(colors: [firstColor, secondColor]),
            startPoint: .top,
            endPoint: .bottom)
    }
    
    func glucoseValueColor(value: Double) -> Color {
        if value < 70 {
            return .black
        } else if value  <  180 {
            return  .green
        } else if value < 250 {
            return  .red
        } else {
            return  .black
        }
    }
    
}

struct GlucoseStats_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("No values")
            SimpleGlucose(
                samplesAndRange: SamplesAndRange(samples:[],
                                                 start: Date.now.advanced(by: -1 * threeHours),
                                                 end: Date.now)
            )
            .frame(maxWidth: .infinity, maxHeight: 350)
            
            Text("Single value")
            SimpleGlucose(
                samplesAndRange: SamplesAndRange(samples:[
                    MetricSample(Date.now.advanced(by: -60 * 60), 100),
                    MetricSample(Date.now.advanced(by: -55 * 60), 100),
                    MetricSample(Date.now.advanced(by: -50 * 60), 145),
                    MetricSample(Date.now.advanced(by: -50 * 60), 145),
                    MetricSample(Date.now.advanced(by: -2 * 60 * 60), 200),
                    MetricSample(Date.now.advanced(by: -3 * 60 * 60), 200)
                ],
                                                 start: Date.now.advanced(by: -3 * 60*60),
                                                 end: Date.now)
            )
            .frame(maxWidth: .infinity, maxHeight: 350)
        }
        //        .background(.blue.opacity(0.04))
    }
}
