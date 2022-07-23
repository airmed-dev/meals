//
//  SimpleGlucose.swift
//  meals
//
//  Created by aclowkey on 02/07/2022.
//

import SwiftUI

//struct SimpleGlucose: View {
//    var aggregatedCapsules: [GlucoseCapsule]?
//    var samples: [MetricSample]
//    var dateAxisEvery = 2
//
//    var glucoseMin = 75
//    var glucoseStepSize = 50
//    var glucoseMax = 300
//
//    var glucoseAxisValues: [Int] {
//        Array(stride(from: glucoseMin, to:glucoseMax, by: glucoseStepSize))
//    }
//
//    func dateAxisLabels(size: CGSize) -> some View {
//        let values = Array ( getDateAxisValues().enumerated().filter { $0.offset % dateAxisEvery == 0} )
//        return ForEach(values, id: \.element.self){ idx, axisValue in
//            Text(formatTime(interval: TimeInterval(axisValue*60)))
//                .position(
//                    x: minutesToPixels(
//                        minutes: idx*getStepSizeMinutes(),
//                        width: size.width
//                    ),
//                    y: size.height
//                )
//        }
//    }
//
//    func valueAxisLabels(size: CGSize, every: Int = 2) -> some View {
//        let values = Array(glucoseAxisValues.enumerated().compactMap { index, value in index % every == 0 ? value : nil})
//        return ForEach(values, id: \.self){ axisValue in
//            Text(String(axisValue))
//                .position(
//                    x: 20,
//                    y: glucoseToPixels(glucose: axisValue, height: size.height)
//                )
//        }
//    }
//
//    func valueAxisGrid(size: CGSize) -> some View {
//        ForEach(glucoseAxisValues, id: \.self){ axisValue in
//            Path { line in
//                let glucosePixels = glucoseToPixels(
//                    glucose: axisValue, height:size.height)
//                line.move(to: CGPoint(x: CGFloat(40), y: glucosePixels))
//                line.addLine(to: CGPoint(x: size.width, y: glucosePixels))
//            }
//            .strokedPath(StrokeStyle.init(lineWidth: 2))
//            .foregroundColor(.black.opacity(0.1))
//        }
//    }
//
//    func dateAxisGrid(size: CGSize) -> some View {
//        ForEach(Array(getDateAxisValues().enumerated()), id: \.element.self){ idx, _ in
//            Path { line in
//                let minutePixels = minutesToPixels(
//                    minutes: idx * getStepSizeMinutes(),
//                    width: size.width
//                )
//                line.move(to: CGPoint(x: minutePixels, y: 0))
//                line.addLine(to: CGPoint(x: minutePixels, y: size.height))
//            }
//            .strokedPath(StrokeStyle.init(lineWidth: 2))
//            .foregroundColor(.black.opacity(0.1))
//        }
//    }
//
//
//
//    var body: some View {
//        let glucoseRanges = aggregate(samples: samples)
//        HStack {
//            VStack {
//                // Glucose Axis
//                GeometryReader { geo in
//                    if samples.count == 0 {
//                        Text("No data")
//                    } else {
//                        // Date axis and labels
//                        dateAxisLabels(size: geo.size)
//                        dateAxisGrid(size: geo.size)
//
//                        // Value axis and labels
//                        valueAxisLabels(size: geo.size)
//                        valueAxisGrid(size: geo.size)
//
//                       // Capsules
//                        ForEach(Array(glucoseRanges.enumerated()), id: \.offset) { index, capsule  in
//                            let glucoseDiff = glucoseDiffToPixels(glucose: Int(capsule.valueMax - capsule.valueMin), height: geo.size.height)
//                            let capsuleWidth = minutesToPixels(minutes: getStepSizeMinutes(), width: geo.size.width) * 0.2
//                            Capsule()
//                                .fill(glucoseRangeGradient(capsule: capsule))
//                                .frame(
//                                    width: capsuleWidth,
//                                    height: glucoseDiff )
//                                .position(
//                                    x: minutesToPixels(minutes: index * 30, width: geo.size.width),
//                                    y: glucoseToPixels(glucose: Int(capsule.valueMax), height: geo.size.height) + glucoseDiff / 2
//                                )
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func aggregate(samples: [MetricSample]) -> [GlucoseCapsule] {
//        let hourInSeconds:Double = 30*60
//        let groupedByClosestHour = Dictionary(grouping: samples, by: { sample in
//            Int(sample.date.timeIntervalSince(event.date) / hourInSeconds)
//        })
//
//        return groupedByClosestHour.map { index, samples in
//            let values = samples.map { v in v.value }
//            let min = values.min()!
//            let max = values.max()!
//            return GlucoseCapsule(valueMin: min, valueMax: max, index: index)
//        }.sorted(by: { $0.index < $1.index})
//
//    }
//
//    func formatTime(interval: TimeInterval) -> String{
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute]
//        formatter.unitsStyle = .positional
//        return formatter.string(from: interval)!
//    }
//
//    func getDateAxisValues() -> [Int]{
//        let diffMinutes = Int(getDateMax().timeIntervalSince(getDateMin())) / 60
//        return Array(stride(from: 0, to: diffMinutes, by: getStepSizeMinutes()))
//    }
//
//    func getDateMax() -> Date {
//        return event.date.addingTimeInterval(threeHours)
//    }
//
//    func getDateMin() -> Date {
//        return event.date
//    }
//
//    func getStepSizeMinutes() -> Int {
//        return 30
//    }
//
//    func glucoseToPixels(glucose: Int, height: CGFloat) -> CGFloat {
//        let offset:CGFloat = -25
//        let fromMin = CGFloat(glucose-glucoseMin)
//        let scale = height / CGFloat(glucoseMax - glucoseMin)
//        return height - fromMin * scale + offset
//    }
//
//    func glucoseDiffToPixels(glucose: Int, height: CGFloat) -> CGFloat {
//        let scale = height / CGFloat(glucoseMax - glucoseMin)
//        return CGFloat(scale) * CGFloat(glucose)
//    }
//
//    func minutesToPixels(minutes: Int, width: CGFloat) -> CGFloat {
//        let offset: CGFloat = width * 0.2
//        let scale = (width-offset) / (getDateMax().timeIntervalSince(getDateMin()) / 60)
//        return offset + CGFloat(minutes) * CGFloat(scale)
//    }
//
//    func glucoseRangeGradient(capsule: GlucoseCapsule) -> LinearGradient{
//        // 0 -> 70: Black to Red.
//        // 70 -> 150 -> green
//        // 150 -> 300 -> Red to black
//        var firstColor: Color
//        var secondColor: Color
//
//        if capsule.valueMax < 70 {
//            firstColor = .black
//        } else if capsule.valueMax <  180 {
//            firstColor = .green
//        } else if capsule.valueMin < 250 {
//            firstColor = .red
//        } else {
//            firstColor = .black
//        }
//
//        if capsule.valueMin < 70 {
//            secondColor = .black
//        } else if capsule.valueMin <  180 {
//            secondColor = .green
//        } else if capsule.valueMin < 250 {
//            secondColor = .red
//        } else {
//            secondColor = .black
//        }
//
//        return LinearGradient(
//            gradient: Gradient(colors: [firstColor, secondColor]),
//            startPoint: .top,
//            endPoint: .bottom)
//
//    }
//
//}
//
//struct GlucoseCapsule:Hashable {
//    var valueMin: Double
//    var valueMax: Double
//    var index: Int
//}
//
//struct SimpleGlucose_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Text("No values")
//            SimpleGlucose(
//                 samples:[]
//            )
//            .frame(maxWidth: .infinity, maxHeight: 350)
//
//            Text("Single value")
//            SimpleGlucose(
//                samples:[
//                    MetricSample(Date.now.advanced(by: 0), 100),
//                    MetricSample(Date.now.advanced(by: -30 * 60), 100),
//                    MetricSample(Date.now.advanced(by: -60 * 60), 120),
//                    MetricSample(Date.now.advanced(by: -180), 100),
//                ]
//            )
//            .frame(maxWidth: .infinity, maxHeight: 350)
//        }
//        //        .background(.blue.opacity(0.04))
//    }
//}
