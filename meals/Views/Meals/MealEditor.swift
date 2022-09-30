//
//  NewMeal.swift
//  meals
//
//  Created by aclowkey on 07/05/2022.
//

import SwiftUI

// MealEditor allows a user to edit a meal
struct MealEditor: View {
    static var placeholderDescription = "Enter a description"
    
    @EnvironmentObject var mealStore: MealStore
    @Environment(\.presentationMode) var presentationMode

    @State var meal: Meal = Meal(id:0, name: "", description: MealEditor.placeholderDescription)

    // Photo
    @State var imageWasSelected = false
    @State var image: UIImage? = nil
    @State var imageDraft: UIImage = UIImage()
    
    @State var showPhotoPickerMenu = false
    @State var showPhotoPickerLibrary = false
    @State var showPhotoPickerCamera = false
    @State var deletePhotoSelected = false
    @State var showDeleteMenu = false
    
    
    // Event handlers
    // onEdit is called when a meal is delete or updated
    var onEdit: () -> Void = { }
    
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
            // Image editor
            GeometryReader { geo in
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        if imageWasSelected {
                            Image(uiImage: imageDraft)
                                .resizable()
                        } else if let image = image{
                            Image(uiImage: image)
                                .resizable()
                        } else {
                            VStack {
                               Image(systemName: "photo.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(LinearGradient(
                                colors: [Color(hex: 0xffd89b), Color(hex: 0x19547b)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .opacity(0.5)
                        }
                    }
                    
                    Button(action: {showPhotoPickerMenu.toggle() }) {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                            Text("Photo")
                                .foregroundColor(.white)
                        }
                        .padding(15)
                        .background(.primary)
                        .cornerRadius(15)
                    }
                    .padding()
                }

            }
            
            // Meal fields
            List {
                HStack {
                    Text("Name")
                        .bold()
                    Spacer()
                    TextField("Enter meal name", text: $meal.name)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .bold()
                    TextEditor(text: $meal.description)
                        .foregroundColor(
                            meal.description == MealEditor.placeholderDescription
                            ? .gray
                            : .primary
                        )
                        .onTapGesture {
                            if meal.description == MealEditor.placeholderDescription {
                                meal.description = ""
                            }
                        }
                }
            }
            .listStyle(.inset)
//            .cornerRadius(5, corners:[.topLeft, .topRight])
//            .offset(y: -10)
            
            Spacer()
            
            // Buttons
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
                if meal.id != 0{
                    Spacer()
                    LoadingButton(status: deleteButtonStatus,
                                  role: .destructive,
                                  label: "Delete",
                                  loadingLabel: "Deleting..",
                                  doneLabel: "Deleted"){
                        showDeleteMenu = true
                    }
                }
            }
            .padding()
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
            Button("Ok", role: .cancel){}
        }
        .alert(successMessage, isPresented: $showSuccessAlert) {
            Button("Ok", role: .cancel){
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func save(meal: Meal, image: UIImage?) {
        saveButtonStatus = .Clicked
        do {
            try mealStore.saveMeal(meal: meal, image: image)
            saveButtonStatus = .Saved
            showSuccessAlert = true
            successMessage = "Saved '\(meal.name)'"
            onEdit()
        } catch {
            self.errorMessage = "Failed saving: \(error)"
            self.showErrorAlert = true
            saveButtonStatus = .Initial
        }
    }
    
    func delete(meal: Meal){
        deleteButtonStatus = .Clicked
        do {
            try mealStore.deleteMeal(meal: meal)
            deleteButtonStatus = .Saved
            showSuccessAlert = true
            successMessage = "Delete \(meal.name)"
            onEdit()
        } catch {
            self.errorMessage = "Failed deleting: \(error)"
            self.showErrorAlert = true
            deleteButtonStatus = .Initial
        }
    }
}

struct MealEditor_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // With default empty meal
            MealEditor()
            
            // With an existing meal
            MealEditor(
                meal: Meal(
                    id: 1,
                    name: "A delicious meal",
                    description: "Some desciprtion for the meal"
                ),
                    // TODO: Load from assets?
                image: nil
            )
        }
    }
}
