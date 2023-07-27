//
//  LaundryView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/07/23.
//

import SwiftUI
import UIKit
import CoreData

struct LaundryView: View {
    @ObservedObject var closetManager: ClosetManager
    @State private var selectedItemType: String = "All"
    @State private var searchText = ""
    @State private var selectedItems: Set<ClosetItemEntity> = Set()
    @State private var selectedItem: ClosetItemEntity?
    @State private var isSelecting: Bool = false
    @State private var laundryFeedback = false

    var sortedItems: [ClosetItemEntity] {
        let filteredItems = closetManager.items
            .filter { selectedItemType == "All" || $0.itemType == selectedItemType }
            .filter { $0.isAvailable == false }
        
        if searchText.isEmpty {
            return filteredItems.sorted(by: { $0.itemDate! > $1.itemDate! })
        } else {
            return filteredItems.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $selectedItemType, label: Text("Filter")) {
                    Text("All").tag("All")
                    Text("Jackets").tag("jackets")
                    Text("Tops").tag("tops")
                    Text("Bottoms").tag("bottoms")
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity, alignment: .center)
                
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
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.accentColor, lineWidth: 2)
                                        )
                                }
                                VStack(alignment: .leading) {
                                    ItemLabel(title: "Name", value: item.name ?? "")
                                    ItemLabel(title: "Color", value: item.color ?? "")
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
            .onAppear {
                closetManager.getAllItems()
            }
            .navigationTitle("Laundry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSelecting.toggle()
                        selectedItems.removeAll()
                    }) {
                        Text(isSelecting ? "Cancel" : "Select")
                    }
                }
            }
            
            if isSelecting {
                HStack {
                    Button(action: {
                        for item in selectedItems {
                            closetManager.deleteItem(id: item.id!)
                        }
                        selectedItems.removeAll()
                        isSelecting.toggle()
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
                        
                        Text("Add to Closet")
                            .foregroundColor(.blue)
                            .padding()
                            .cornerRadius(12)
                    }
               

                }
                .padding()
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .scrollIndicators(.hidden)
        
    }
    func toggleLaundry(for item: ClosetItemEntity) {
        item.isAvailable.toggle()
        CoreDataStack.shared.saveContext()
        
        let feedbackMessage = "Added to Closet"
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
    LaundryView(closetManager: ClosetManager())
}
