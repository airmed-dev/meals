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
    @State var meal: Meal?
    @State var event: Event
    @State var image: UIImage?
    
    @State var fetchInsulin: Bool = false
    var width: CGFloat = 5
    
    var body: some View {
        VStack{
            if let meal = meal {
                VStack {
                    HStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 150)
                                .clipShape(Circle())
                        }
                        
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
            List {
                Section {
                    Text("Glucose")
                    MetricGraph(event: event, dataType: .Glucose )
                        .frame(height: 200)
                        .border(.black)
                }
                Section {
                    Text("Insulin")
                    MetricGraph(event: event, dataType: .Insulin )
                        .frame(height: 200)
                        .border(.black)
                }
                HStack{
                    Text(event.date.formatted())
                }
            }
        }
        .onAppear {
            if let meal = meal {
                PhotosAPI.getPhoto(meal: meal) { result in
                    switch result {
                    case .success(let loadedImage):
                        image = loadedImage
                    case .failure(let error):
                        print("Failed loading image: \(error)")
                    }
                }
            }
        }
    }
    
    
}

struct MetricView_Previews: PreviewProvider {
    static var previews: some View {
        let mealID:Int = 0
        MetricView(
            meal: Meal(id: mealID, name: "Blueberries", description: "Yummy meal"),
            event: Event(meal_id: mealID, id: 3, date: Date.now)
        )
    }
}
