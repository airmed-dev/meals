//
//  Chart.swift
//  meals
//
//  Created by aclowkey on 01/10/2022.
//

import SwiftUI

struct Chart: View {
    var data: [ChartData] = []
    
    var startIndex: Int
    var endIndex: Int
    var indexStepSize: Int
    var indexFormatter: (Int) -> String
    
    var startValue: Double
    var endValue: Double
    var valueStepSize: Double
    
    var color: Color
    
    var body: some View {
        LabeledAxisGrid(
            rowLabels: rowLabels,
            columnLabels: columnLabels
        )
        .overlay {
            // Capsules
            GeometryReader { geo in
                ForEach(data, id: \.index){ data in
                    let position = chartDataPosition(size: geo.size, data: data)
                    let height = chartDataHeight(height: geo.size.height, data: data)
                    Capsule()
                        .frame(width: 15, height: height)
                        .position(
                            x: position.x,
                            y: position.y
                        )
                        .foregroundColor(color)
                }
            }
        }
        .padding(.leading, 10)
    }
    
    var columnLabels: [String] {
        stride(from: startIndex, through: endIndex, by: indexStepSize)
            .map { indexFormatter($0) }
    }
    
    var rowLabels: [String] {
        Array(stride(
            from: startValue,
            through: endValue,
            by: valueStepSize
        ))
        .map { String("\(formatValue(number: $0 as NSNumber))") }
    }
    
    func formatValue(number: NSNumber) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: number)!
    }
    
    
    func chartDataHeight(height: CGFloat, data: ChartData) -> CGFloat {
        valueToPixels(
            height: height,
            value: endValue - (data.valueMax - data.valueMin)
        )
    }
    
    func chartDataPosition(size: CGSize, data: ChartData) -> CGPoint {
        let x = indexToPixels(width: size.width,  index:data.index)
        
        let height = chartDataHeight(height: size.height, data: data)
        let y = valueToPixels(height: size.height, value: data.valueMin) - height/2
        
        return CGPoint(x: x, y: y)
    }
    
    func indexToPixels(width: CGFloat, index: Double) -> CGFloat {
        // TODO: 60 is the amount of pixels that goes to the right side legend
        // should be a constant?
        index * ( (width-120) / CGFloat(endIndex - startIndex))
    }
                       
                       
    func valueToPixels(height: CGFloat, value: Double) -> CGFloat {
        let scale = (height-60) / (endValue - startValue)
        return (endValue - value) * scale
    }
    

}

struct ChartData: Hashable {
    var index: Double
    var valueMin: Double
    var valueMax: Double
}

struct Chart_Previews: PreviewProvider {
    let data = Array(stride(from: 0 ,through: 10, by: 1)).map { index in
                ChartData(
                    index: index,
                    valueMin: 75+index*10,
                    valueMax: 75 + index*20
                )
            }
    static var previews: some View {
        Chart(
            data: [
                ChartData(index: 0, valueMin: 75, valueMax: 300),
                ChartData(index: 1, valueMin: 75, valueMax: 225),
                ChartData(index: 2, valueMin: 75, valueMax: 150),
                
                ChartData(index: 3, valueMin: 150, valueMax: 300),
                ChartData(index: 4, valueMin: 225, valueMax: 300),
                ChartData(index: 5, valueMin: 250, valueMax: 300),
                
                ChartData(index: 6, valueMin: 80, valueMax: 140),
                ChartData(index: 7, valueMin: 160, valueMax: 215),
                ChartData(index: 8, valueMin: 235, valueMax: 290)
            ],
            startIndex: 0,
            endIndex: 10,
            indexStepSize: 2,
            indexFormatter: { a in String(a) },
            
            startValue: 75,
            endValue: 300,
            valueStepSize: 75,
            color: .red
        )
        .frame(height: 200)
        .padding()
//        .cornerRadius(1)
    }
}
