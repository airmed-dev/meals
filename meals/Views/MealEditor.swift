//
//  NewMeal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

// MealEditor allows a user to edit a meal
struct MealEditor: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var meal: Meal
    var newMeal: Bool = false
    
    var onSave: (Meal) -> Void
    
    var body: some View {
        VStack {
            Form {
                // Meal fields
                HStack {
                    Text("Name")
                        .bold()
                    Spacer()
                    TextField("Meal name", text: $meal.name)
                }
                Text("Description")
                    .bold()
                TextEditor(text: $meal.description)
                    .accessibilityHint("Enter meal description")

            }
            Spacer()
            HStack(alignment: .firstTextBaseline){
                Button("Save") {
                    onSave(meal)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
            
        
    }
    
}

struct MealEditor_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal(id: UUID(), name: "", description: "")
        MealEditor(meal: meal,
                   onSave: {meal in print("Saved", meal) })
    }
}
