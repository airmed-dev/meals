//
//  SimpleGlucose.swift
//  meals
//
//  Created by aclowkey on 02/07/2022.
//

import SwiftUI

struct SimpleGlucose: View {
    @State var glucoseCapsules: [GlucoseCapsule]
    @State var glucoseBlockSize = 50
    @State var glucoseBlockCount = 4
    
    var body: some View {
        VStack {
//           GeometryReader { geo in
//               // Axises
//               let xPixels = geo.size.width / (CGFloat(glucoseCapsules.count)+1)
//               ForEach(1...glucoseCapsules.count, id: \.self){step in
//                   Path { path in
//                       path.move(to: CGPoint(x: Int(xPixels) * step, y: 0))
//                       path.addLine(to: CGPoint(x: xPixels*CGFloat(step), y: geo.size.height))
//                   }
//                   .strokedPath(StrokeStyle.init(lineWidth: 1))
//                   .foregroundColor(.black.opacity(0.2))
//               }
//
//               let yPixels = Int(geo.size.height) / (glucoseBlockCount)
//               ForEach(1...glucoseBlockCount, id: \.self){ step in
//                   Path { path in
//                       let y:CGFloat = CGFloat(step*yPixels)
//                       path.move(to: CGPoint(x: 0, y:y ))
//                       path.addLine(to: CGPoint(x: geo.size.width, y: y ))
//                   }
//                   .strokedPath(StrokeStyle.init(lineWidth: 1))
//                   .foregroundColor(.black.opacity(0.2))
//               }
//
//               // Capsules
//               ForEach(Array(glucoseCapsules.enumerated()), id: \.offset) { index, glucoseCapsule in
//                   let y = geo.size.height - ((glucoseCapsule.valueMin / glucoseBlockSize) * yPixels)
//
//                   Capsule()
//                       .fill(Color(hex: 0xee00000))
//                       .frame(width: 50, height: 20)
//                       .position(x: CGFloat(index+1)*xPixels, y: y)
//               }
//           }
        }
    }
}

struct GlucoseCapsule:Hashable {
    var valueMin: Double
    var valueMax: Double
}

struct SimpleGlucose_Previews: PreviewProvider {
    static var previews: some View {
        SimpleGlucose(glucoseCapsules: [
            GlucoseCapsule(valueMin: 100, valueMax: 100),
            GlucoseCapsule(valueMin: 100, valueMax: 150),
            GlucoseCapsule(valueMin: 150, valueMax: 130),
            GlucoseCapsule(valueMin: 150, valueMax: 130),
        ])
        .background(Color(hex: 0xeeeeeeee))
        .padding(30)
    }
}
