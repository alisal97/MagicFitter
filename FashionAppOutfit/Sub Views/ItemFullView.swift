//
//  ItemView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 03/06/23.
//

import SwiftUI

struct FullView: View {
    let item: ClosetItemEntity
    @ObservedObject var closetManager: ClosetManager
    @State private var isEditing = false
    @State var showGeneratedOutfit = false
    @State var generatedOutfitItems: [ClosetItemEntity] = []
    @State private var showFeedback = false
    @Environment(\.presentationMode) var presentationMode
    @State private var includeJacket = true
    @State private var showDeleteConfirmation = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    HStack {
                        if let imageData = item.imageData, let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 370 * 0.75 , height: 335 * 0.75)
                                .shadow(radius: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                            
                        }
                    }
                    HStack {
                        VStack {
                            Button(action: {
                                updateAvailability()
                            }) {
                                HStack {
                                    Image(systemName: item.isAvailable ? "square" : "checkmark.square.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.accentColor)
                                        .padding(3)
                                    Text(item.isAvailable ? "Add to Laundry" : "In Laundry")
                                        .foregroundColor(.accentColor)
                                }
                                .cornerRadius(8)
                                .padding(10)
                            }
                        }
                        .padding(.leading)
                        VStack {
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.trailing)
                    }
                    
                }
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 235, height: 170)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ItemLabel(title: "Name", value: item.name ?? "")
                        HStack{
                            Image(systemName: "eyedropper")
                                .font(.system(size: 20))
                                .foregroundColor(.accentColor)
                            
                            Text("Color:")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                                .fontWeight(.bold)
                            HStack {
                                Circle()
                                    .fill(Color(item.color ?? "Color"))
                                    .frame(width: 15)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 1.5)
                                    )
                                
                                Text(item.color ?? "")
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)

                            }
                        }
                        ItemLabel(title: "Type", value: item.itemType ?? "")
                        ItemLabel(title: "Style", value: item.itemStyle ?? "")
                    }
                }
                HStack {
                    if let itemType = ItemType(rawValue: item.itemType ?? ""), itemType != .jackets && item.isAvailable {
                        Picker(selection: $includeJacket, label: Text("Include Jacket")) {
                            Text("Summer").tag(false)
                            Text("Winter").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .foregroundColor(.accentColor)
                    } else {
                        Picker(selection: .constant(true), label: Text("Include Jacket")) {
                            Text("Summer").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .foregroundColor(.accentColor)
                        .disabled(true)
                        .hidden()
                    }
                }
                
                if showFeedback {
                    Text("No matching items were found in your wardrobe")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                Button(action: {
                    if item.isAvailable {
                        closetManager.generatedOutfitItems(chosenItem: item, includeJacket: includeJacket)
                        if closetManager.generatedOutfitItems.isEmpty {
                            showFeedback = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    showFeedback = false
                                }
                            }
                        } else {
                            self.generatedOutfitItems = closetManager.generatedOutfitItems.compactMap { $0 }
                            self.showGeneratedOutfit = true
                        }
                    }
                }) {
                    HStack {
                        Text("Match")
                            .foregroundColor(item.isAvailable ? .accentColor : .gray)
                            .fontWeight(.bold)
                            .padding(.horizontal, 47)
                            .padding(.vertical, 13)
                            .opacity(item.isAvailable ? 1.0 : 0.7)
                            .padding(.leading, 59)
                        
                        Image(systemName: "wand.and.stars.inverse")
                            .resizable()
                            .frame(width: 65, height: 65)
                            .foregroundColor(item.isAvailable ? .accentColor : .gray)
                            .opacity(item.isAvailable ? 1.0 : 0.7)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color.gray.opacity(0.35))
                    )
                    .opacity(item.isAvailable ? 1.0 : 0.7)
                    .allowsHitTesting(item.isAvailable)
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Item"),
                        message: Text("Are you sure you want to delete this item?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Delete")) {
                            deleteItem()
                        }
                    )
                }
                .sheet(isPresented: $showGeneratedOutfit) {
                    GeneratedOutfitView(outfitItems: generatedOutfitItems, item: item)
                }
            }
            .toolbarBackground(
                .ultraThinMaterial
                ,for: .navigationBar
            )
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                closetManager.getAllItems()
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                isEditing = true
            }) {
                Text("Edit")
                    .fontWeight(.semibold)
                    .foregroundColor(.white )
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                    .background(Color.gray)
                    .cornerRadius(20)
            }
            )
        }
        .sheet(isPresented: $isEditing) {
            EditView(item: item, closetManager: closetManager, isEditing: $isEditing)
            
        }
    }
    
    func updateAvailability() {
        if item.isAvailable {
            item.isAvailable = false
        } else if !item.isAvailable {
            item.isAvailable = true
        }
        closetManager.getAllItems()
        CoreDataStack.shared.saveContext()
    }
    
    
    func deleteItem() {
        DispatchQueue.main.async {
            closetManager.deleteItem(id: item.id!)
            presentationMode.wrappedValue.dismiss() // Dismiss the view
        }
    }
}



