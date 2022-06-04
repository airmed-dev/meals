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
    let mealStore: MealStore = MealStore()
    let photoStore = PhotoStore()
    
    @State var meal: Meal?
    @State var event: Event
    
    @State var fetchInsulin: Bool = false
    var width: CGFloat = 5
    
    var body: some View {
        VStack{
            if let meal = meal {
                VStack {
                    HStack {
                        photoStore.getImage(meal: meal)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .clipShape(Circle())
                        
                        VStack {
                            Text(meal.name)
                                .font(.headline)
                            Text(event.date.ISO8601Format())
                                .font(.footnote)
                        }
                    }
                }
            }
            
            Spacer()
            MetricGraph(
                event: event,
                start: event.date,
                end: event.date,
                fetchInsulin: fetchInsulin
            )
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
        let mealID = UUID()
        MetricView(
            meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
            event: Event(meal_id: mealID, id: UUID(), date: Date.now)
        )
    }
}
