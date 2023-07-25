//
//  EditView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 03/06/23.
//

import SwiftUI


struct EditView: View {
    let item: ClosetItemEntity
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var closetManager: ClosetManager // Add the observed object
    @Binding var isEditing: Bool // Add the binding for the isEditing state
    
    @State private var itemName: String
    @State private var selectedColor: String
    @State private var selectedItemType: ItemType
    @State private var selectedImage: UIImage?
    @State private var selectedItemStyle: ItemStyle

    
    @State private var showContextMenu = false
    @State private var showImagePicker = false
    @State private var showCameraView = false

    var itemTypes: [ItemType] = [.jackets, .tops, .bottoms] // Replace with actual cases
    let colors = ["Yellow", "Green", "Orange", "Violet", "Blue", "Red", "Pink", "Black", "White", "Beige", "Light Blue", "Brown", "Gray"];

    init(item: ClosetItemEntity, closetManager: ClosetManager, isEditing: Binding<Bool>) {
        self.item = item
        self.closetManager = closetManager
        self._isEditing = isEditing
        
        // Initialize the state properties
        self._itemName = State(initialValue: "")
        self._selectedColor = State(initialValue: "")
        self._selectedItemType = State(initialValue: .tops)
        self._selectedImage = State(initialValue: nil)
        
        // Set the state properties after the initializers
        self._itemName = State(initialValue: item.name ?? "")
        self._selectedColor = State(initialValue: item.color ?? "")
        self._selectedItemType = State(initialValue: ItemType(rawValue: item.itemType ?? "") ?? .tops)
        self._selectedImage = State(initialValue: item.imageData.flatMap(UIImage.init))
        self._selectedItemStyle = State(initialValue: ItemStyle(rawValue: item.itemStyle ?? "") ?? .both)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Item Details")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding()

                Spacer() // Add a spacer to push the ZStack to the top
                
                ZStack(alignment: .topTrailing) { // Set the alignment to topTrailing
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: 335 * 0.67, height: 370 * 0.67)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor, lineWidth: 2)
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
                TextField("Name", text: $itemName)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.accentColor)
                    .padding()
                
                
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
                        .pickerStyle(.menu)
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
                    HStack {
                        Text("Style:")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.leading)

                        Picker("Style", selection: $selectedItemStyle) {
                            ForEach(ItemStyle.allCases, id: \.self) { itemStyle in
                                Text(itemStyle.rawValue.capitalized).tag(itemStyle)
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
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: 175)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.gray.opacity(0.35))
                    .cornerRadius(12)
                }
                .padding()
                .padding(.bottom)
                
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
            ImagePickerView(sourceType: .camera) { image in
                selectedImage = image
            }
        }

        .onTapGesture {
            endEditing() // Dismiss the keyboard when tapped outside the text field
        }
        .onAppear {
            itemName = item.name ?? ""
            selectedColor = item.color ?? ""
            selectedItemType = ItemType(rawValue: item.itemType ?? "") ?? .tops
        }
        .padding(.top, 15) // Adjust the top padding to move the content lower
    }
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func saveItem() {
        // Update the item properties
        item.name = itemName
        item.color = selectedColor
        item.itemType = selectedItemType.rawValue
        item.itemStyle = selectedItemStyle.rawValue
        
        // Save the changes using the ClosetManager
        closetManager.editItem(id: item.id!, itemType: selectedItemType, itemStyle: selectedItemStyle, newName: itemName, newColor: selectedColor, newImage: selectedImage)
        
        // Set isEditing to false to dismiss the view
        isEditing = false
    }

}


//struct EditView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditView(item: item, closetManager: closetManager, isEditing: true)
//    }
//}
