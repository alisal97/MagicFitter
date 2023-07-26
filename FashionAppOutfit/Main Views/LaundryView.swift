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
        NavigationView {
            VStack {
                Picker(selection: $selectedItemType, label: Text("Filter")) {
                    Text("All").tag("All")
                    Text("Jackets").tag("jackets")
                    Text("Tops").tag("tops")
                    Text("Bottoms").tag("bottoms")
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
                    }
                }
                .listStyle(.plain)
            }
            .onAppear {
                closetManager.getAllItems()
            }
            .navigationTitle("Laundry")
            .navigationBarTitleDisplayMode(.large)
//            .navigationBarItems(trailing:            )
            .searchable(text: $searchText, prompt: "Search")
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .scrollIndicators(.hidden)
    }}

#Preview {
    LaundryView(closetManager: ClosetManager())
}
