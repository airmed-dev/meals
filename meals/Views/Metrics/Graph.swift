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
    
    let dateRange: (Date, Date)
    let valueRange: (Double, Double)
    
    var width: CGFloat = 7
    
    let textPadding:CGFloat = -15
    var debug = false
    
    var body: some View {
        VStack {
            GeometryReader { geomtry in
                // Glucose values
                let normalizedGraph = normalizeGraph(
                    samples: samples,
                    width: geomtry.size.width, height: geomtry.size.height,
                    dateMin: dateRange.0, dateMax: dateRange.1,
                    valueMin: Double(valueRange.0), valueMax: Double(valueRange.1)
                )
                ForEach(normalizedGraph, id: \.id) { sample in
                    Circle()
                        .fill(getPointColor(point: sample))
                        .frame(width: width, height: width)
                        .position(x: sample.x, y: sample.y)
                }
                
                // Range axises
                let valueScale = CGFloat(valueRange.1 - valueRange.0)
                let logBar = geomtry.size.height / valueScale
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
                
            }.background(LinearGradient(colors: [
                Color(hex: 0x360033),
                Color(hex: 0x0b8793)
            ],
                                        startPoint: .top,
                                        endPoint: .bottom))
            HStack {
                Text(dateRange.0.formatted())
                Spacer()
                Text(dateRange.1.formatted())
            }
        }
        
        
    }
    
    func getPointColor(point: GraphPoint) -> Color{
        return Color.white
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
                id: "\(Int(x))"
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
                MetricSample(Date.init(timeIntervalSinceNow: -500), 100),
                MetricSample(Date.init(timeIntervalSinceNow: -400), 100),
                MetricSample(Date.init(timeIntervalSinceNow: -300), 100),
                MetricSample(Date.init(timeIntervalSinceNow: -200), 100),
                MetricSample(Date.init(timeIntervalSinceNow: -100), 100),
                MetricSample(Date.init(timeIntervalSinceNow: 0), 100),
            ],
            dateRange: (Date.init(timeIntervalSinceNow: -500), end: Date.now),
            valueRange: ( 40,  400),
            debug: true
        )
        .frame(width: 300, height: 300)
    }
}
