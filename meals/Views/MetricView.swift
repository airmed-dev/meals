//
//  MetricView.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI

struct MetricView: View {
    @State var event: Event
   
    var body: some View {
        VStack{
            MetricGraph(
                samplePoints: [
                    MetricSample(Date.init(timeIntervalSinceNow: 0), 150),
                    MetricSample(Date.init(timeIntervalSinceNow: 60), 70),
                    MetricSample(Date.init(timeIntervalSinceNow: 120), 70),
                    MetricSample(Date.init(timeIntervalSinceNow: 240), 70),
                    MetricSample(Date.init(timeIntervalSinceNow: 280), 70),
                    MetricSample(Date.init(timeIntervalSinceNow: 300), 90),
                    MetricSample(Date.init(timeIntervalSinceNow: 300), 90),
                    MetricSample(Date.init(timeIntervalSinceNow: 300), 190),
                    MetricSample(Date.init(timeIntervalSinceNow: 300), 350),
                ],
                start: Date.now,
                end: Date.now
            )
            .frame(height: 300)
            HStack{
                Text(event.date.formatted())
            }
            Spacer()
        }
    }
}

struct MetricView_Previews: PreviewProvider {
    static var previews: some View {
        MetricView(
            event: Event(meal_id: UUID(), id: UUID(), date: Date.now)
        )
    }
}
