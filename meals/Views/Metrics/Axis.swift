//
//  Axis.swift
//  meals
//
//  Created by aclowkey on 01/07/2022.
//

import Foundation
import SwiftUI


struct Axis: View {
    let start: Double
    let end: Double
    let stepSize: Double
    
    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { geo in
                let pixelSize = geo.size.height / (end - start)
                ForEach(getSteps(), id: \.self){ val in
                    Text(String(val))
                        .position(x: 20, y: geo.size.height - (val-start) * pixelSize)
                }
            }
        }
    }
    
    func getSteps() -> [Double]{
       var steps:[Double] = []
       var value = start
        
       while value <= end {
           steps.append(round(value*100) / 100)
           value += stepSize
       }
        
       return steps
    }
}


struct Axis_Previews: PreviewProvider {
    static var previews: some View {
        Axis(start: 0, end: 1, stepSize: 0.2)
            .background(.cyan)
            .padding(100)
    }
}
