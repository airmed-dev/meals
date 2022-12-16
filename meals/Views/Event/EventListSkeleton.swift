//
// Created by aclowkey on 24/09/2022.
//

import Foundation
import Darwin
import SwiftUI

struct EventListSkeleton: View {
    var body: some View {
        headerSkeleton
        statisticsSkeleton
        timelineSkeleton
    }

    // Skeletons sections
    var headerSkeleton: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(uiColor: .systemGray6),
                    Color(uiColor: .systemGray5),
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .frame(height: 150)
            
            HStack {
                VStack(alignment: .leading) {
                    textSkeleton
                        .frame(width: 200)
                        .frame(height: 15)
                    textSkeleton
                        .frame(width: 100)
                        .frame(height: 10)
                }
            }
            .padding()
        }
    }

    var statisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Statistics")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .padding(.leading, 5)
                        .padding(.top, 5)
                Spacer()
            }
            withAnimation(.spring()) {
                glucoseStatisticsSkeleton
            }
            insulinStatisticsSkeleton
                    .animation(.spring())
        }
    }

    var timelineSkeleton: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("Timeline")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .padding(.top, 5)
                        .padding(.leading, 10)
            }
                    .frame(height: 20)
                    .padding(.trailing, 10)

            ScrollView(.horizontal) {
                HStack {
                    timelineCardSkeleton(true)
                    timelineCardSkeleton()
                    timelineCardSkeleton()
                    timelineCardSkeleton(true)
                    timelineCardSkeleton()
                }
            }
                    .frame(height: 150)
                    .padding(.top, 5)
                    .padding(.bottom, 15)
                    .padding(.leading, 3)
                    .padding(.trailing, 3)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
        }
    }

    // Skeleton subcomponenets
    var glucoseStatisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Glucose")
                        .font(.subheadline)
                        .padding(.leading, 5)
                        .padding(.top, 5)
                Spacer()
            }
            statisticsGraphSkeleton
            Spacer()
        }
    }

    var insulinStatisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Insulin")
                        .font(.subheadline)
                        .padding(.leading, 5)
                        .padding(.top, 5)
                Spacer()
            }
            statisticsGraphSkeleton
            Spacer()
        }
    }

    var statisticsGraphSkeleton: some View {
        ZStack {
            Rectangle()
                    .foregroundColor(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
            GeometryReader { geo in
                let xOffset:CGFloat = 5
                let yOffset:CGFloat = 30
                let stepSize = geo.size.width/30
                let pointSize:CGFloat = 10
                let xValues = Array(stride(
                    from: xOffset,
                    to: geo.size.width,
                    by: stepSize
                ))
                
                let yRange = (geo.size.height - yOffset) / 2
                ForEach( xValues , id: \.self ) { xValue in
                    let yValue = yRange + sin(CGFloat(xValue / stepSize)) * pointSize
                    Circle()
                            .foregroundColor(Color(uiColor: .systemGray3))
                            .frame(
                                width: pointSize,
                                height: pointSize
                            )
                            .position(
                                x: xValue,
                                y: yOffset + yValue
                            )
                }
            }
        }
                .padding(.leading, 3)
                .padding(.trailing, 3)
    }

    func timelineCardSkeleton(_ displayDateSkeleton: Bool = false) -> some View {
        VStack {
            VStack {
                if displayDateSkeleton {
                    textSkeleton
                }
            }
                    .frame(height: 10)

            textSkeleton
                    .frame(height: 10)
            Rectangle()
                    .foregroundColor(Color(uiColor: .systemGray5))
                    .cornerRadius(10)
                    .frame(width: 100)
        }
                .padding(.leading, 10)
                .padding(.bottom, 5)
    }

    var textSkeleton: some View {
        HStack {
            Rectangle()
                    .foregroundColor(Color(uiColor: .systemGray3))
                    .cornerRadius(10)
            Spacer()
        }
    }

}


struct EventListSkeleton_Previews: PreviewProvider {
    static var previews: some View {
        EventListSkeleton()
    }
}
