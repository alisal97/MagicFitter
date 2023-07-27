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
    @State private var selectedItemStyle: ItemStyle = .casual
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
        NavigationStack {
            VStack {
                Text("Add an item!")
                    .font(.headline)
                    .bold()
                    .padding()
                    .foregroundColor(.accentColor)
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: 335 * 0.67, height: 370 * 0.67)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                    
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 335 * 0.67, height: 370 * 0.67)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                        
                        Button(action: {
                        }) {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding()
                        }
                        .simultaneousGesture(TapGesture()
                            .onEnded({ _ in
                                selectedImage = nil
                            }))
                        .padding(8)
                        
                    } else {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 75 * 0.67, height: 75 * 0.67)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .offset(x: -130 * 0.67 , y: 150 * 0.67)
                                .onTapGesture {
                                    showContextMenu = true
                                }
                            
                        }
                    }
                }
            }
            
            ZStack  {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 373, height: 350)
                VStack {
                    VStack(alignment: .leading) {
                        TextField("Name", text: $itemName)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                endEditing()
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Color")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.leading)

                        Picker(selection: $selectedColor, label: Text("")) {
                            ForEach(colors, id: \.self) { color in
                                HStack {
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 23)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.accentColor, lineWidth: 1.5)
                                        )
                                    
                                    Text(color)
                                }
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .padding(.trailing, 150)
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Type")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.leading)

                        Picker(selection: $selectedItemType, label: Text("")) {
                            ForEach(itemTypes, id: \.self) { itemType in
                                Text(itemType.rawValue.capitalized).tag(itemType)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Style")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.leading)

                        
                        Picker(selection: $selectedItemStyle, label: Text("")) {
                            ForEach(ItemStyle.allCases, id: \.self) { itemStyle in
                                Text(itemStyle.rawValue.capitalized).tag(itemStyle)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Button(action: {
                            saveItem()
                        }) {
                            Text("Save")
                                .foregroundColor(.accentColor.opacity(saveButtonOpacity))
                                .frame(maxWidth: 300, alignment: .center)
                                .padding()
                                .fontWeight(.bold)
                                .background(Color.gray.opacity(0.35))
                                .cornerRadius(12)
                        }
                    }
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
                .scrollIndicators(.never)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    endEditing()
                }
            }
        }
        }
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func saveItem() {
        guard let image = selectedImage else { return }

        closetManager.addItem(name: itemName, color: selectedColor, itemType: selectedItemType, itemStyle: selectedItemStyle, image: image, isAvailable: true)


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
