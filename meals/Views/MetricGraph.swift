//
//  MetricGraph.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MetricGraph: View {
    @State var samplePoints: [MetricSample] = []
    @State var start: Date
    @State var end: Date
    var width: CGFloat = 5
    
    var body: some View {
        GeometryReader { geomtry in
            Path { path  in
                let normalizedGraph = normalizeGraph(
                    width: Int(geomtry.size.width),
                    height: Int(geomtry.size.height)
                )
                path.move(to: normalizedGraph[0])
                
                normalizedGraph.dropFirst().forEach { samplePoint in
                    path.addLine(to: samplePoint)
                }
                
            }
            .strokedPath(StrokeStyle.init(lineWidth: width, lineCap: .round ))
            .foregroundColor(.blue)
        }
    }
    
    func normalizeGraph(width: Int, height: Int) -> [CGPoint] {
        let floor: Float = 50
        let ceil: Float = 300

        
        return samplePoints.enumerated().map { sampleIndex, samplePoint in
            let xScale = width / (samplePoints.count)
            let yScale = 2
            
            let y = height - Int(samplePoint.value-floor) * Int(yScale)
            return CGPoint(x: sampleIndex*xScale, y: y)
        }
    }
}


struct MetricGraph_Previews: PreviewProvider {
    static var previews: some View {
        MetricGraph(samplePoints: [
            MetricSample(Date.init(timeIntervalSinceNow: 480), 70),
            MetricSample(Date.init(timeIntervalSinceNow: 420), 850),
            MetricSample(Date.init(timeIntervalSinceNow: 360), 120),
            MetricSample(Date.init(timeIntervalSinceNow: 300), 125),
            MetricSample(Date.init(timeIntervalSinceNow: 240), 140),
            MetricSample(Date.init(timeIntervalSinceNow: 180), 180),
            MetricSample(Date.init(timeIntervalSinceNow: 120), 175),
            MetricSample(Date.init(timeIntervalSinceNow: 60), 160),
            MetricSample(Date.init(timeIntervalSinceNow: 0), 160),
        ],
                    start: Date.init(timeIntervalSinceNow: 1000),
                    end:Date.now)
    }
}
