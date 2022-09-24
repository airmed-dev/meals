//
// Created by aclowkey on 24/09/2022.
//

import Foundation
import SwiftUI

struct EventListSkeleton: View {
    var body: some View {
        headerSkeleton
        statisticsSkeleton
        timelineSkeleton
    }

    // Skeletons sections
    var headerSkeleton: some View {
        HStack(alignment: .firstTextBaseline) {
            Circle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(uiColor: .systemGray3))
            VStack {
                Spacer()
                HStack {
                    textSkeleton.frame(height: 30)
                    Spacer()
                }
                HStack {
                    textSkeleton
                            .frame(height: 10)
                    Spacer()
                }
                Spacer()
            }
            Spacer()
        }
                .frame(height: 100)
                .padding(.leading, 5)
    }

    var statisticsSkeleton: some View {
        VStack {
            HStack {
                Text("Statistics")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .padding(.leading, 5)
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
            HStack {
                Text("Timeline")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .padding(.top, 5)
                        .padding(.leading, 10)
                Spacer()
                Circle()
                        .foregroundColor(Color(uiColor: .systemGray3))
                        .frame(width: 25)
                        .frame(height: 25)
                        .overlay {
                            Image(systemName: "plus")
                                    .padding()
                        }
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
                ForEach(
                        Array(stride(from: 30, to: geo.size.width, by: geo.size.width/7)), id: \.self
                ) { index in
                    Rectangle()
                            .foregroundColor(Color(uiColor: .systemGray3))
                            .frame(width: 30, height: geo.size.height*0.8)
                            .cornerRadius(15)
                            .position(x: index, y: geo.size.height/2)
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
