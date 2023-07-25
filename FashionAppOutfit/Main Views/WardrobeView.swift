//
//  WardrobeView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/07/23.
//

import SwiftUI

struct WardrobeView: View {
    @State private var showModal = false // Added state variable
    @ObservedObject var closetManager: ClosetManager // Use the same instance of ClosetManager
    @State private var selectedItemType: String = "All"

    var sortedItems: [ClosetItemEntity] {
        return closetManager.items
            .filter { selectedItemType == "All" || $0.itemType == selectedItemType }
            .sorted(by: { $0.itemDate! > $1.itemDate! })
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
                .frame(width: 330 )
                .pickerStyle(.segmented)
                List {
                    ForEach(sortedItems, id: \.id) { item in
                        NavigationLink(
                            destination: FullView(item: item, closetManager: closetManager),
                            label: {
                                HStack {
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
                        )
                        //                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .onAppear {
                closetManager.getAllItems()
            }
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                Button(action: {
                    showModal = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 21, weight: .bold))
                        .padding(15)
                }
            )
            .sheet(isPresented: $showModal) {
                AddItemView(closetManager: closetManager)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    WardrobeView(closetManager: ClosetManager())
}
