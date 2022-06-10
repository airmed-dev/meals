//
//  Graph.swift
//  meals
//
//  Created by aclowkey on 10/06/2022.
//

import SwiftUI
import Foundation


struct Graph: View {
    var samples: [MetricSample] = []
    var start: Date
    var end: Date
    
    var width: CGFloat = 7
    let glucoseMin = 40
    let glucoseMax = 400
    
    let rangeMin: Double = 70
    let rangeMax: Double = 180
    
    let textPadding:CGFloat = -15
    var debug = false
    
    var body: some View {
        VStack {
            GeometryReader { geomtry in
                // Glucose values
                let normalizedGraph = normalizeGraph(
                    samples: samples,
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
            }
        }
        .background(Color(uiColor: UIColor.systemBackground))
    }
    
    func formatAsTime(date:Date) -> String {
        let hourlyFormatter = DateFormatter()
        hourlyFormatter.dateFormat = "HH:mm"
        return hourlyFormatter.string(from: date)
    }
    
    func normalizeGraph(samples: [MetricSample],
                        width: Double, height: Double,
                        dateMin: Date, dateMax: Date,
                        valueMin: Double, valueMax: Double) -> [GraphPoint] {
        let xScale = width / (dateMax.timeIntervalSince(dateMin) / 60.0)
        let yScale = height / Double(valueMax-valueMin)
        
        return samples.enumerated().map { _, samplePoint in
            
            let y = height - samplePoint.value * yScale
            let x = (samplePoint.date.timeIntervalSince(dateMin) / 60.0)
                    * xScale
            return GraphPoint(
                x: x,
                y: y,
                value: samplePoint.value,
                id: "\(x)"
            )
        }
    }
}


struct GraphPoint: Identifiable, Equatable {
    let x: Double
    let y: Double
    let value: Double
    let id: String
}

struct Graph_Previews: PreviewProvider {
    static var previews: some View {
        Graph(
            samples: [
                MetricSample(Date.init(timeIntervalSinceNow: 480), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 150),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 200),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
                MetricSample(Date.init(timeIntervalSinceNow: 240), 250),
            ],
            start: Date.init(timeIntervalSinceNow: 90),
            end: Date.now,
            debug: true
        )
        .frame(width: 300, height: 300)
    }
}
