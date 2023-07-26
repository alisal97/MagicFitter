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
    @State private var isSelecting: Bool = false
    
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
    var body: some View {
        NavigationView {
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
                        HStack {
                            if isSelecting {
                                // Show checkboxes in selection mode
                                Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
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
                        .onTapGesture {
                            if isSelecting {
                                toggleSelection(item)
                            } else {
                                NavigationStack {
                                    FullView(item: item, closetManager: closetManager)
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
            .navigationTitle("Closet")
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
                            item.isAvailable = false
                        }
                        selectedItems.removeAll()
                        isSelecting.toggle()
                    }) {
                        
                        Text("Add to Laundry")
                            .foregroundColor(.accentColor)
                            .padding()
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
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

                }
                .padding()
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .scrollIndicators(.hidden)
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
