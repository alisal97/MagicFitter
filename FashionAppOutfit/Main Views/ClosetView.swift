//
//  WardrobeView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/07/23.
//

import SwiftUI
import UIKit
import CoreData

struct ClosetView: View {
    @ObservedObject var closetManager: ClosetManager
    @State private var selectedItemType: String = "All"
    @State private var searchText = ""
    @State private var selectedItems: Set<ClosetItemEntity> = Set()
    @State private var selectedItem: ClosetItemEntity?
    @State private var isSelecting: Bool = false
    @State private var laundryFeedback = false
    @State private var showDeleteConfirmation = false
    @State private var showModal = false
    

    var sortedItems: [ClosetItemEntity] {
        let filteredItems = closetManager.items
            .filter { selectedItemType == "All" || $0.itemType == selectedItemType }
            .filter { $0.isAvailable }
        
        if searchText.isEmpty {
            return filteredItems.sorted(by: { $0.itemDate! > $1.itemDate! })
        } else {
            return filteredItems.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }
    
    var cancelButton: some View {
        Button(action: {
            isSelecting.toggle()
            selectedItems.removeAll()
        }) {
            Text(isSelecting ? "Cancel" : "Select")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 6)
                .background(Color.gray)
                .cornerRadius(20)

        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Picker(selection: $selectedItemType, label: Text("Filter")) {
                        Text("All").tag("All")
                        Text("Jackets").tag("jackets")
                        Text("Tops").tag("tops")
                        Text("Bottoms").tag("bottoms")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal)
                    Spacer()
                    if closetManager.items.isEmpty {
                        Text("Your closet is empty. Tap the \"+\" button in the bottom right corner to start populating your virtual closet!.")
                            .font(.headline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 275)
                    } else {
                        List {
                            ForEach(sortedItems, id: \.id) { item in
                                NavigationLink(destination: FullView(item: item, closetManager: closetManager))  {
                                    HStack {
                                        if isSelecting {
                                            Image(systemName: selectedItems.contains(item) ? "checkmark.square.fill" : "square")
                                                .onTapGesture {
                                                    toggleSelection(item)
                                                }
                                        }
                                        
                                        if let imageData = item.imageData, let image = UIImage(data: imageData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .scaledToFill()
                                                .aspectRatio(contentMode: .fill)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.accentColor, lineWidth: 2)
                                                )
                                        }
                                        VStack(alignment: .leading, spacing: 8) {
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
                                                }
                                            }
                                            ItemLabel(title: "Type", value: item.itemType ?? "")
                                            ItemLabel(title: "Style", value: item.itemStyle ?? "")
                                            
                                            
                                        }
                                        
                                    }
                                }
                                .onTapGesture {
                                    if isSelecting {
                                        // Toggle the selection state of the item
                                        if selectedItems.contains(item) {
                                            selectedItems.remove(item)
                                        } else {
                                            selectedItems.insert(item)
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        .listStyle(.plain)
                    }
                }
                FloatingButton(action: {
                    showModal = true
                }, icon: "plus")
            }
            .onAppear {
                closetManager.getAllItems()
            }
            .navigationTitle("Closet")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                    Button(action: {
                        isSelecting.toggle()
                        selectedItems.removeAll()
                    }) {
                        Text(isSelecting ? "Cancel" : "Select")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 6)
                            .background(Color.gray)
                            .cornerRadius(20)
                    }
                )
                .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if isSelecting && selectedItems.count > 0 {
                        HStack {
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Text("Delete Items")
                                    .foregroundColor(.red)
                                    .padding()
                                    .cornerRadius(12)
                            }
                            Spacer()
                            Button(action: {
                                for item in selectedItems {
                                    toggleLaundry(for: item)
                                }
                                selectedItems.removeAll()
                                isSelecting.toggle()
                            }) {
                                Text("Add to Laundry")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showModal) {
                AddItemView(closetManager: closetManager)
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Items"),
                message: Text("Are you sure you want to delete the selected Items?"),
                primaryButton: .cancel(Text("Cancel").foregroundColor(.accentColor)),
                secondaryButton: .destructive(Text("Delete")) {
                    deleteSelectedItems()
                    selectedItems.removeAll()
                    isSelecting.toggle()
                }
            )
        }
        .searchable(text: $searchText, prompt: "Search")
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .scrollIndicators(.hidden)
        
    }
    
    func deleteSelectedItems() {
        for item in selectedItems {
            closetManager.deleteItem(id: item.id!)
        }
    }
    func toggleLaundry(for item: ClosetItemEntity) {
        item.isAvailable.toggle()
        CoreDataStack.shared.saveContext()
        
        let feedbackMessage = "Added to Laundry"
        let feedbackAlert = UIAlertController(title: nil, message: feedbackMessage, preferredStyle: .alert)
        
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
              rootViewController.present(feedbackAlert, animated: true, completion: nil)
        }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                feedbackAlert.dismiss(animated: true, completion: nil)
                
            }
        }

    private func toggleSelection(_ item: ClosetItemEntity) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
}

#Preview {
    ClosetView(closetManager: ClosetManager())
}
