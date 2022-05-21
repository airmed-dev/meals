//
//  MetricView.swift
//  meals
//
//  Created by aclowkey on 14/05/2022.
//

import SwiftUI
import HealthKit

enum HealthkitError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
}
                    
let threeHours: Double = 3 * 60 * 60

struct MetricView: View {
    @State var event: Event
    var width: CGFloat = 5
   
    var body: some View {
        VStack{
            Spacer()
            MetricGraph(event: event, start: event.date, end: event.date)
                .frame(width: 300)
                .border(.black)
            Spacer()
            HStack{
                Text(event.date.formatted())
            }
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
