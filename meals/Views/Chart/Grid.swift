//
//  Grid.swift
//  meals
//
//  Created by aclowkey on 01/10/2022.
//

import SwiftUI

struct Grid: View {
    var strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1)
    var rowCount: Int
    var columnCount: Int
    
    var body: some View {
        GeometryReader{ geo in
            // Vertical lines
            drawColumns(size: geo.size)
            drawRows(size: geo.size)
        }
    }
    func drawRows(size: CGSize) -> some View {
        let sizePixels = size.height / CGFloat(rowCount)
        var positions: [CGFloat] = []
        for index in (0...rowCount){
            positions.append(CGFloat(index) * sizePixels)
        }
        return ForEach(positions, id: \.self){ position in
            Path { path in
                path.move(to: CGPoint(x: 0, y: position))
                path.addLine(to: CGPoint(x: size.width, y: position))
            }
            .stroke(style: strokeStyle)
        }
    }
    
    func drawColumns(size: CGSize) -> some View {
        let sizePixels = size.width / CGFloat(columnCount)
        var positions: [CGFloat] = []
        for index in (0...columnCount){
            positions.append(CGFloat(index) * sizePixels)
        }
        return ForEach(positions, id: \.self){ position in
            Path { path in
                path.move(to: CGPoint(x: position, y: 0))
                path.addLine(to: CGPoint(x: position, y: size.height))
            }
            .stroke(style: strokeStyle)
        }
    }
    
}

struct Grid_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Text("Grid ratio: 1:1")
                Text("Frame ratio: 1:1")
            }
            Grid(rowCount: 4, columnCount: 4)
                .frame(width: 300, height: 300)
        }
        VStack {
            Text("Grid ratio: 1:1")
            Text("Frame ratio: 3:4")
            Grid(rowCount: 4, columnCount: 4)
                .frame(width: 360, height: 270)
        }
        
        VStack {
            Text("Grid ratio: 3:4")
            Text("Frame ratio: 3:4")
            Grid(rowCount: 3, columnCount: 4)
                .frame(width: 300, height: 270)
        }
    }
}


