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
    @State var generatedOutfitItems: [ClosetItemEntity] = [] // Update the type to [ClosetItemEntity]
    @State private var showFeedback = false
    @Environment(\.presentationMode) var presentationMode
    @State private var includeJacket = true // Track user's selection for including a jacket item
    @State private var showDeleteConfirmation = false // Track whether the delete confirmation should be shown
    @State private var isAvailable = true // Track the availability of the item
    
    var body: some View {
        NavigationStack {
            HStack {
                Text(item.name ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .bold()
                    .padding(.leading)
                    .frame(maxWidth: 300, alignment: .leading) // Center the text
            }

            ScrollView {
                
                VStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(width: UIScreen.main.bounds.width * 0.95 , height: UIScreen.main.bounds.height * 0.3)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        HStack(spacing: 10) {
                            VStack {
                                HStack {
                                    if let imageData = item.imageData, let image = UIImage(data: imageData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 145, height: 175)
                                            .cornerRadius(8)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }

                                }

                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 2)

                                )

                                HStack {
                                    Button(action: {
                                        isAvailable.toggle()
                                        updateAvailability()
                                    }) {
                                        Image(systemName: item.isAvailable ? "checkmark.square.fill" : "square")
                                            .resizable()
                                            .fontWeight(.bold)
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(isAvailable ? .accentColor : .gray)
                                    }
                                    Text(item.isAvailable ? "Available" : "In Laundry")
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 32)
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Spacer()
                                
                                HStack {
                                    Label("", systemImage: "eyedropper")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                    Text(item.color ?? "")
                                        .font(.headline)
                                        .fontWeight(.regular)
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.bottom, 15)
                                HStack {
                                    Label("", systemImage: "tag.fill")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                    Text(item.itemType ?? "")
                                        .font(.headline)
                                        .fontWeight(.regular)
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.bottom, 15)
                                
                                HStack {
                                    Label("", systemImage: "sparkle")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                    Text(item.itemStyle ?? "")
                                        .font(.headline)
                                        .fontWeight(.regular)
                                        .foregroundColor(.accentColor)
                                }

                                Spacer()
                                HStack {
                                    if let itemType = ItemType(rawValue: item.itemType ?? ""), itemType != .jackets && item.isAvailable {
                                        Toggle(isOn: $includeJacket) {
                                            Text("Include Jacket")
                                                .fontWeight(.bold)
                                                .foregroundColor(.accentColor)
                                        }
                                    } else {
                                        Toggle(isOn: .constant(true)) {
                                            Text("Include Jacket")
                                                .fontWeight(.bold)
                                                .foregroundColor(.accentColor)
                                        }
                                        .disabled(true)
                                    }
                                }
                                    Spacer()
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    
                    if showFeedback {
                        Text("No matching items were found in your wardrobe")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    
                    Spacer()
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
                        if item.isAvailable {
                            Text("Match")
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.gray.opacity(0.35))
                                .cornerRadius(12)
                        } else {
                            Text("Match")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.gray.opacity(0.35))
                                .cornerRadius(12)
                                .disabled(true)
                                .allowsHitTesting(true)

                        }
                    }
                    .padding(.top)
                    .padding(.horizontal, 32)
                    Spacer()
                    Button(action: {
                        showDeleteConfirmation = true // Show the delete confirmation alert
                    }) {
                        Text("Delete Item")
                            .foregroundColor(.red)
                            .frame(maxWidth: 175)
                            .padding()
                            .background(Color.gray.opacity(0.35))
                            .cornerRadius(12)
                    }
                    .padding(.top)
                    .padding(.horizontal, 32)
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
                    
                }
                .padding(.bottom, 200)
                .listStyle(PlainListStyle())

                .sheet(isPresented: $showGeneratedOutfit) {
                    GeneratedOutfitView(outfitItems: generatedOutfitItems, item: item) // Update the reference to generatedOutfitItems
                }
            }
            
        }
        .toolbarBackground(
            .ultraThinMaterial
            ,for: .navigationBar
        )
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing = true // Set isEditing to true to show the edit sheet
                }) {
                    Text("Edit")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                        .fontWeight(.regular)
                }
                .sheet(isPresented: $isEditing) {
                    EditView(item: item, closetManager: closetManager, isEditing: $isEditing)
                }

            }
        }
    }
    
    func updateAvailability() {
        item.isAvailable = isAvailable
        CoreDataStack.shared.saveContext()
    }
    
    
    func deleteItem() {
        DispatchQueue.main.async {
            closetManager.deleteItem(id: item.id!)
            presentationMode.wrappedValue.dismiss() // Dismiss the view
        }
    }
}

