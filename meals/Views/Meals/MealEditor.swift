//
//  NewMeal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

// MealEditor allows a user to edit a meal
struct MealEditor: View {
    let mealStore = MealStore()
    let photoStore = PhotoStore()
    
    @Environment(\.presentationMode) var presentationMode
    @State var meal: Meal
    
    var newMeal: Bool = false
    
    @State var showPhotoPickerMenu = false
    @State var showPhotoPickerLibrary = false
    
    @State var imageDraft: UIImage = UIImage()
    @State var imageWasSelected = false
    
    var body: some View {
        VStack {
            Form {
                ZStack(alignment: .bottomTrailing) {
                    if imageWasSelected {
                        Image(uiImage: imageDraft)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        photoStore.getImage(meal: meal)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    
                    Button(action: {showPhotoPickerMenu.toggle() }) {
                       Image(systemName: "plus")
                           .frame(width: 50, height: 50)
                            .background(Color( red: 27, green: 27, blue: 27))
                           .clipShape(Circle())
                    }
                    .padding(10)
                }
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
                    var photo: UIImage? = nil
                    if imageWasSelected {
                        photo = imageDraft
                    }
                    save(meal: meal, photo: photo)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .confirmationDialog("Select a source", isPresented: $showPhotoPickerMenu, titleVisibility: .visible) {
            Button("Photo library"){
                print("Photo library selected")
                showPhotoPickerLibrary = true
            }
            Button("Camera"){
                print("Camera selected")
            }
        }
        .sheet(isPresented: $showPhotoPickerLibrary){
            ImagePicker(
                selectedImage: $imageDraft,
                wasSelected: $imageWasSelected,
                sourceType: .photoLibrary
            )
        }
    }
    
    func save(meal: Meal, photo: UIImage?){
        mealStore.load { result in
            switch result {
            case .success(var meals):
                meals.append(meal)
                mealStore.save(meals: meals) { result in
                    switch result {
                    case .success(let count):
                        print("Save \(count) meals")
                    case .failure(let error):
                        print("Failed saving a new meal: \(error)")
                    }
                }
                if let photoSelected = photo {
                    photoStore.saveImage(meal: meal, image: photoSelected)
                }
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }

    }
}

struct MealEditor_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal(id: UUID(), name: "", description: "")
        MealEditor(meal: meal)
    }
}
