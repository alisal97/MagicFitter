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
    @ObservedObject var closetManager: ClosetManager
    @Binding var isEditing: Bool
    
    @State private var itemName: String
    @State private var selectedColor: String
    @State private var selectedItemType: ItemType
    @State private var selectedImage: UIImage?
    @State private var selectedItemStyle: ItemStyle
    
    
    @State private var showContextMenu = false
    @State private var showImagePicker = false
    @State private var showCameraView = false
    
    var itemTypes: [ItemType] = [.jackets, .tops, .bottoms]
    let colors = ["Yellow", "Green", "Orange", "Violet", "Blue", "Red", "Pink", "Black", "White", "Beige", "Light Blue", "Brown", "Gray"];
    
    var saveButtonOpacity: Double {
        if selectedImage != nil && !itemName.isEmpty {
            return 1.0
        } else {
            return 0.15
        }
    }
    
    
    init(item: ClosetItemEntity, closetManager: ClosetManager, isEditing: Binding<Bool>) {
        self.item = item
        self.closetManager = closetManager
        self._isEditing = isEditing
        
        self._itemName = State(initialValue: "")
        self._selectedColor = State(initialValue: "")
        self._selectedItemType = State(initialValue: .tops)
        self._selectedImage = State(initialValue: nil)
        self._selectedItemStyle = State(initialValue: .both)
        
        self._itemName = State(initialValue: item.name ?? "")
        self._selectedColor = State(initialValue: item.color ?? "")
        self._selectedItemType = State(initialValue: ItemType(rawValue: item.itemType ?? "") ?? .tops)
        self._selectedImage = State(initialValue: item.imageData.flatMap(UIImage.init))
        self._selectedItemStyle = State(initialValue: ItemStyle(rawValue: item.itemStyle ?? "") ?? .both)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Item Details")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding()
                                
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: 335 * 0.67, height: 370 * 0.67)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding()
                        }
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
                ZStack  {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 373, height: 420)
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
                        Divider()
                            .frame(width: 370)
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
                        Divider()
                            .frame(width: 370)
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
                        Divider()
                            .frame(width: 370)
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
                        Divider()
                            .frame(width: 370)
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
            .scrollIndicators(.never)
            .scrollDismissesKeyboard(.immediately)
            
            .onTapGesture {
                endEditing()
            }
        }
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

