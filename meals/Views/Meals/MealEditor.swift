//
//  NewMeal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

// MealEditor allows a user to edit a meal
struct MealEditor: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var meal: Meal
    @State var image: UIImage? = nil
    
    var newMeal: Bool = false
    
    @State var showPhotoPickerMenu = false
    @State var showPhotoPickerLibrary = false
    @State var showPhotoPickerCamera = false
    @State var deletePhotoSelected = false
    
    @State var showDeleteMenu = false
    
    @State var imageDraft: UIImage = UIImage()
    @State var imageWasSelected = false
    
    // Callbacks
    var onCompletion: () -> Void = {}
    
    // Buttons
    @State var saveButtonStatus: ButtonStatus = .Initial
    @State var deleteButtonStatus: ButtonStatus = .Initial
    
    // Alerts
    @State var showSuccessAlert: Bool = false
    @State var successMessage: String = ""
    
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if imageWasSelected {
                    Image(uiImage: imageDraft)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if let image = image{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                   Image(systemName: "photo.fill")
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
                LoadingButton(status: saveButtonStatus,
                              label: "Save",
                              loadingLabel: "Saving..",
                              doneLabel: "Saved"){
                    var photo: UIImage? = nil
                    if imageWasSelected {
                        photo = imageDraft
                    } else if let image = image {
                        photo = image
                    }
                    save(meal: meal, image: photo)
                }
                Spacer()
                LoadingButton(status: deleteButtonStatus,
                              role: .destructive,
                              label: "Delete",
                              loadingLabel: "Deleting..",
                              doneLabel: "Deleted"){
                    showDeleteMenu = true
                }
            }
            .padding()
        }
        .onAppear {
            // TODO: Fetching photo
        }
        .confirmationDialog("Select a source", isPresented: $showPhotoPickerMenu, titleVisibility: .visible) {
            Button("Photo library"){
                showPhotoPickerLibrary = true
            }
            Button("Camera"){
                showPhotoPickerCamera = true
            }
            if image != nil {
                Button("Delete", role: .destructive){
                    image = nil
                }
            }
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
        .alert(isPresented: $showDeleteMenu) {
            Alert(title: Text("Are you sure you want to delete this meal?"),
                  primaryButton:
                    .destructive(Text("Yes")){
                        delete(meal: meal)
                    },
                  secondaryButton: .cancel()
            )
        }
        .alert(errorMessage, isPresented: $showErrorAlert){
            Button("Ok", role: .cancel){
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(successMessage, isPresented: $showSuccessAlert) {
            Button("Ok", role: .cancel){
                onCompletion()
            }
        }
    }
    
    func save(meal: Meal, image: UIImage?) {
        saveButtonStatus = .Clicked
        viewModel.saveMeal(meal: meal, image: image)
    }
    
    func delete(meal: Meal){
        // TODO: viewMode.delete(meal)
    }
}

struct MealEditor_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal(id: 1, name: "", description: "")
        MealEditor(meal: meal)
    }
}
