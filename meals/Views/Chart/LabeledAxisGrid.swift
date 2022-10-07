//
//  Chart.swift
//  meals
//
//  Created by aclowkey on 01/10/2022.
//

import SwiftUI

struct LabeledAxisGrid: View {
    var rowLabels: [String]
    var columnLabels: [String]
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack {
                    Grid(
                        rowCount: rowLabels.count - 1,
                        columnCount: columnLabels.count - 1
                    )
                    .foregroundColor(.gray.opacity(0.5))
                    
                    RowAxis(values: rowLabels)
                        .frame(
                            width: getValueAxisWidth(
                                usingFont: UIFont.systemFont(ofSize: UIFont.systemFontSize)
                            )
                        )
                        .padding(.leading, 15)
                }
                ColumnAxis(values: columnLabels)
                    .frame(width:
                            geo.size.width -
                            getValueAxisWidth(
                                usingFont: UIFont.systemFont(ofSize: UIFont.systemFontSize)
                            ) - 22,
                           height: getValueAxisWidth(
                                usingFont: UIFont.systemFont(ofSize: UIFont.systemFontSize)
                            )
                    )
                    .padding(.top, 10)
            }
        }
    }
    
    func getValueAxisWidth(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = "XXXX".size(withAttributes: fontAttributes)
        return size.width
    }
}

struct ColumnAxis: View {
    var values: [String]
    var body: some View {
        VStack {
            GeometryReader { geo in
                drawValue(size: geo.size)
            }
        }
    }
    
    func drawValue(size: CGSize) -> some View{
        let sizePixels = size.width / (CGFloat(values.count - 1))
        return ForEach(Array(values.enumerated()), id: \.element.self) { offset, element in
            Text(element)
                .position(
                    x: CGFloat(offset) * (sizePixels)
                )
        }
    }
    
    func calculateOffset(offset: CGFloat) -> CGFloat {
        let fontSize = valueAxisWidth(
            usingFont: UIFont.systemFont(ofSize: UIFont.systemFontSize)
        )
        if offset == 0 {
            return fontSize / 2
        }
        return 0
    }
    
    func valueAxisWidth(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = values.last!.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct RowAxis: View {
    var values: [String]
    var body: some View {
        VStack {
            GeometryReader { geo in
                drawValue(size: geo.size)
            }
        }
    }
    
    func drawValue(size: CGSize) -> some View{
        let sizePixels = size.height / (CGFloat(values.count-1))
        return ForEach(Array(values.reversed().enumerated()), id: \.element.self) { offset, element in
           Text(element)
                .position(y: CGFloat(offset) * sizePixels)
        }
    }
    
    func calculateOffset(offset: CGFloat) -> CGFloat {
      return 0
    }
}

struct LabeledAxisGrid_Previews: PreviewProvider {
    static var previews: some View {
        LabeledAxisGrid(
            rowLabels: ["1", "2", "3", "4", "5", "6"],
            columnLabels: ["A", "B", "C", "E", "G", "H", "I", "J"]
        )
        .padding()
    }
}
