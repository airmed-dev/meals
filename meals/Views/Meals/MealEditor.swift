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
    @State var image: Image = Image(systemName: "photo.fill")
    
    var newMeal: Bool = false
    
    @State var showPhotoPickerMenu = false
    @State var showPhotoPickerLibrary = false
    @State var showPhotoPickerCamera = false
    
    @State var showDeleteMenu = false
    
    @State var imageDraft: UIImage = UIImage()
    @State var imageWasSelected = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if imageWasSelected {
                    Image(uiImage: imageDraft)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                Button(action: {showPhotoPickerMenu.toggle() }) {
                    Image(systemName: "plus")
                        .frame(width: 50, height: 50)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            Spacer()
            // Meal fields
            List {
                HStack {
                    Text("Name")
                        .bold()
                    Spacer()
                    TextField("Meal name", text: $meal.name)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .bold()
                    TextEditor(text: $meal.description)
                        .accessibilityHint("Enter meal description")
                }
            }
            
            Spacer()
            HStack(alignment: .firstTextBaseline){
                Button("Save") {
                    var photo: UIImage? = nil
                    if imageWasSelected {
                        photo = imageDraft
                    }
                    save(meal: meal, photo: photo)
                }
                Spacer()
                Button(role: .destructive, action:  {
                    showDeleteMenu = true
                }, label: {
                    Text("Delete")
                })
            }
            .padding()
        }
        .onAppear {
            PhotosAPI.getPhoto(meal: meal) { result in
                switch result {
                case .success(let loadedImage):
                    image = loadedImage
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        .confirmationDialog("Select a source", isPresented: $showPhotoPickerMenu, titleVisibility: .visible) {
            Button("Photo library"){
                showPhotoPickerLibrary = true
            }
            Button("Camera"){
                showPhotoPickerCamera = true
            }
        }
        .alert(isPresented: $showDeleteMenu) {
            Alert(title: Text("Are you sure you want to delete this meal?"),
                  primaryButton: .destructive(Text("Yes")){
                delete(meal: meal)
            },
                  secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showPhotoPickerLibrary){
            ImagePicker(
                selectedImage: $imageDraft,
                wasSelected: $imageWasSelected,
                sourceType: .photoLibrary
            )
        }
        .sheet(isPresented: $showPhotoPickerCamera){
            ImagePicker(
                selectedImage: $imageDraft,
                wasSelected: $imageWasSelected,
                sourceType: .camera
            )
        }
    }
    
    func save(meal: Meal, photo: UIImage?) {
        MealsAPI.saveMeal(meal: meal, photo: photo) { result in
            switch result {
            case .success(_):
                print("Success")
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error saving meal: \(error)")
            }
        }
    }
    
    func delete(meal: Meal){
        MealsAPI.deleteMeal(meal: meal) { result in
            switch result {
            case .success(_):
                print("Success")
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Failed deleteing meal: \(error)")
            }
        }
    }
}

struct MealEditor_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal(id: 1, name: "", description: "")
        MealEditor(meal: meal)
    }
}
