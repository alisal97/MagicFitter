//
//  AddItemView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/05/23.
//

import SwiftUI

struct AddItemView: View {
    @State private var itemName = ""
    @State private var selectedColor = "White"
    @State private var selectedItemType: ItemType = .tops
    @State private var selectedImage: UIImage?
    @State private var showContextMenu = false
    @State private var showImagePicker = false
    @State private var showCameraView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let colors = ["Yellow", "Green", "Orange", "Violet", "Blue", "Red", "Pink", "Black", "White", "Beige", "Light Blue", "Brown", "Gray"];

    var itemTypes: [ItemType] = [.jackets, .tops, .bottoms] // Replace with actual cases
    
    let closetManager: ClosetManager
    
    init(closetManager: ClosetManager) {
        self.closetManager = closetManager
    }
    var saveButtonOpacity: Double {
        if selectedImage != nil && !itemName.isEmpty {
            return 1.0
        } else {
            return 0.15
        }
    }

    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Add an item!")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundColor(.accentColor)

                Spacer() // Add a spacer to push the ZStack to the top
                
                ZStack(alignment: .topTrailing) { // Set the alignment to topTrailing
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: 335, height: 370)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )

                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 335, height: 370)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )

                        Button(action: {
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding()
                        }
                        .padding(8) // Add padding to the button
                    
                    } else {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 75, height: 75)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .offset(x: -130, y: 150)
                                .onTapGesture {
                                    showContextMenu = true
                                }

                        }
                    }
                }

                TextField("Name", text: $itemName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        endEditing() // Dismiss the keyboard when tapped outside the text field
                    }
                
                Spacer(minLength: 15)
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Color:")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.leading)
                        Picker("Color", selection: $selectedColor) {
                            ForEach(colors, id: \.self) { color in
                                Text(color).tag(color)
                            }
                        }
                        .pickerStyle(.automatic)
                        .frame(maxWidth: .infinity) // Expand the picker to fill the available width
                        .padding(.trailing, 57.5)


                    }
                    .padding(.trailing)

                    .padding(.bottom, 15)
                    
                    HStack {
                        Text("Type:")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.leading)

                        
                        Picker("Type", selection: $selectedItemType) {
                            ForEach(itemTypes, id: \.self) { itemType in
                                Text(itemType.rawValue.capitalized).tag(itemType)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity) // Expand the picker to fill the available width
                        .padding(.trailing, 75)
                    }
                    .padding(.trailing)

                }
                .padding(.trailing)

                Spacer(minLength: 35)
                Button( action: {
                    saveItem()
                }) {
                    Text("Save")
                    .foregroundColor(.accentColor.opacity(saveButtonOpacity))
                    .frame(maxWidth: 175)
                    .padding()
                    .fontWeight(.bold)
                    .background(Color.gray.opacity(0.35))
                    .cornerRadius(12)
                }
                
                Spacer()
                
            }
            
            .actionSheet(isPresented: $showContextMenu) {
                ActionSheet(title: Text("Add Image"), buttons: [
                    .default(Text("Take Photo")) {
                        showCameraView = true
                    },
                    .default(Text("Choose from Gallery")) {
                        showImagePicker = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: .photoLibrary) { image in
                    selectedImage = image
                }
            }
            .fullScreenCover(isPresented: $showCameraView) {
                CamViewWrapper { image in
                    selectedImage = image
                    showCameraView = false
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            endEditing() // Dismiss the keyboard when tapped outside the text field
        }

    }

    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func saveItem() {
        guard let image = selectedImage else { return }

        closetManager.addItem(name: itemName, color: selectedColor, itemType: selectedItemType, image: image, isAvailable: true)


        presentationMode.wrappedValue.dismiss()
    }
}
struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        let closetManager = ClosetManager()
        AddItemView(closetManager: closetManager)
    }
}

struct CamViewWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = CamView
    
    private let didCaptureImage: (UIImage) -> Void // Closure parameter
    
    init(didCaptureImage: @escaping (UIImage) -> Void) { // Update the initializer
        self.didCaptureImage = didCaptureImage
    }
    
    func makeUIViewController(context: Context) -> CamView {
        let camView = CamView()
        camView.didCaptureImage = didCaptureImage // Pass the closure to the CamView
        return camView
    }
    
    func updateUIViewController(_ uiViewController: CamView, context: Context) {
        // Update the view controller if needed
    }
}
