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
    
    let colorFunction: (_ point: GraphPoint) -> Color
    
    let gradientColors:[Color]
    let stepSize: Double
    
    var body: some View {
        VStack {
            HStack {
                // Graph values
                VStack {
                    HStack {
                        HStack{
                            Axis(start: valueRange.0, end: valueRange.1, stepSize: stepSize)
                                .frame(width: 50)
                        }
                        Spacer()
                        GeometryReader { geomtry in
                            // Glucose values
                            let normalizedGraph = normalizeGraph(
                                samples: samples,
                                width: geomtry.size.width, height: geomtry.size.height,
                                dateMin: dateRange.0, dateMax: dateRange.1,
                                valueMin: Double(valueRange.0), valueMax: Double(valueRange.1)
                            )
                            if normalizedGraph.count == 0 {
                                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                    .fill(.background)
                                    .frame(width: geomtry.size.width / 2, height: geomtry.size.height / 3)
                                    .position(x: geomtry.size.width / 2, y: geomtry.size.height / 2)
                                    .opacity(0.75)
                                    .shadow(radius: 5)
                                    .overlay {
                                       Text("No data")
                                    }
                            }
                            
                            ForEach(normalizedGraph, id: \.id) { sample in
                                Circle()
                                    .fill(colorFunction(sample))
                                    .frame(width: width, height: width)
                                    .position(x: sample.x, y: sample.y)
                            }
                            
                            // Time axises
                            let xPixels = geomtry.size.width / (dateRange.1.timeIntervalSince(dateRange.0) / 60)
                            let xSteps = 30.0
                            ForEach(Array(stride(from: 0, to: geomtry.size.width, by: xSteps * xPixels)), id: \.self) { x in
                                Path { path in
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x, y: geomtry.size.height ))
                                }
                                .strokedPath(StrokeStyle.init(lineWidth: width/5))
                                .foregroundColor(.white.opacity(0.2))
                            }
                            
                            // Value axies
                            ForEach(getValueAxis(), id: \.self) { y in
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: y))
                                    path.addLine(to: CGPoint(x: geomtry.size.width, y: CGFloat(y)))
                                }
                                .strokedPath(StrokeStyle.init(lineWidth: width/5))
                                .foregroundColor(.white.opacity(0.2))
                            }
                            
                        }.background(LinearGradient(colors: getBackground(),
                                                    startPoint: .top,
                                                    endPoint: .bottom))
                    }
                    // X Axis
                    HStack {
                        Text(formatAsTime(dateRange.0))
                            .offset(x: 60)
                        Spacer()
                        Text(formatAsTime(dateRange.1))
                    }
                }
            
                
            }
        }
    }
    
    func getValueAxis() -> [Double]{
        return Array(stride(from: valueRange.0, to: valueRange.1, by: stepSize))
    }
    
    
    func formatAsTime(_ date:Date) -> String {
        let hourlyFormatter = DateFormatter()
        hourlyFormatter.dateFormat = "HH:mm"
        return hourlyFormatter.string(from: date)
    }
    
    func getBackground() -> [Color] {
       return gradientColors
    }
    
    func normalizeGraph(samples: [MetricSample],
                        width: Double, height: Double,
                        dateMin: Date, dateMax: Date,
                        valueMin: Double, valueMax: Double) -> [GraphPoint] {
        let xScale = width / (dateMax.timeIntervalSince(dateMin) / 60.0)
        let yScale = height / Double(valueMax-valueMin)
        
        return samples.enumerated().map { _, samplePoint in
            
            let y = height - (samplePoint.value - valueMin) * yScale
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
            debug: true,
            colorFunction: {point in Color.white}, gradientColors: [Color.red, Color.blue],
            stepSize: 50
        )
        .frame(width: 300, height: 300)
        Graph(
            samples: [],
            dateRange: (Date.init(timeIntervalSinceNow: -500), end: Date.now),
            valueRange: ( 40,  400),
            debug: true,
            colorFunction: {point in Color.white}, gradientColors: [Color.red, Color.blue],
            stepSize: 50
        )
        .frame(width: 300, height: 300)
    }
}
