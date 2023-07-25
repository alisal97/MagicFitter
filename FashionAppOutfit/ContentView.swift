//
//  ContentView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 23/05/23.
//

import SwiftUI
import UIKit
import CoreData

struct ContentView: View {
    
    let closetManager = ClosetManager() // Create an instance of ClosetManager
    @Environment(\.colorScheme) var colorScheme // Access the color scheme
    var body: some View {
        TabView {
            
            WardrobeView(closetManager: closetManager) // Pass the closetManager to WardrobeView
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Wardrobe")
                    
                }
            
            
            outfitsView(closetManager: closetManager) // Pass the closetManager to HistoryView
                .tabItem {
                    Image(systemName: "bookmark.circle")
                    Text("Outfits")
                }

            
        }
        .accentColor(colorScheme == .dark ? Color.white : Color.black)
        .background(colorScheme == .dark ? Color.black : Color.white)
        

    }
    
}

struct outfitsView: View {
    @State private var generatedOutfit: [[ClosetItemEntity]] = []
    @ObservedObject var closetManager: ClosetManager
    
    @FetchRequest(entity: OutfitEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \OutfitEntity.date, ascending: false)])
    var allOutfits: FetchedResults<OutfitEntity>
    
    @State private var selectedOutfit: OutfitEntity?
    
    @State private var isSelectMode = false
    @State private var selectedOutfits: Set<OutfitEntity> = []
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""
    @State private var selectedSegment = 0 // Track the selected segment index
    
    var filteredOutfits: [OutfitEntity] {
        if selectedSegment == 0 {
            // Show all outfits
            return Array(allOutfits)
        } else {
            // Show favorite outfits
            return Array(allOutfits.filter { $0.isFavorite })
        }
    }
    
    var displayedOutfits: [OutfitEntity] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty {
            return filteredOutfits
        } else {
            return filteredOutfits.filter { outfit in
                let outfitName = (outfit.outfitName ?? "").lowercased()
                return outfitName.contains(query)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Picker("Segmented menu", selection: $selectedSegment) {
                        Text("All").tag(0)
                        Text("Favorites").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                ForEach(displayedOutfits, id: \.self) { outfit in
                    NavigationLink(destination: SavedOutfitView(outfit: outfit)) {
                        HStack {
                            if isSelectMode {
                                Image(systemName: outfit.isSelected ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.accentColor)
                                    .frame(width: 22, height: 22)
                                    .onTapGesture {
                                        toggleSelection(for: outfit)
                                    }
                            }
                            if let imageData = outfit.outfitPic, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 55, height: 55)
                                    .clipShape(RoundedRectangle(cornerRadius: 8 ))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    )
                            }
                            
                            Text(outfit.outfitName ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .padding()
                        .swipeActions {
                            Button(action: {
                                toggleFavorite(for: outfit)
                            }) {
                                Label(outfit.isFavorite ? "Unfavorite" : "Favorite", systemImage: outfit.isFavorite ? "heart.fill" : "heart")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDisappear {
                        cancelSelection()
                    }
                    
                    .onTapGesture {
                        if isSelectMode {
                            toggleSelection(for: outfit)
                        } else {
                            selectedOutfit = outfit
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.3) {
                        enterSelectMode()
                        toggleSelection(for: outfit)
                    }
                }
                .onDelete { indexSet in
                    showDeleteConfirmation = true
                }
            }
            .navigationTitle("Outfits")
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelectMode {
                        Button(action: cancelSelection) {
                            Text("Cancel")
                                .fontWeight(.bold)
                        }
                    } else {
                        Button(action: enterSelectMode) {
                            Text("Select")
                                .fontWeight(.bold)
                        }
                    }
                }
                if isSelectMode && selectedOutfits.count > 0 {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Text("Delete")
                                    .padding()
                                    .foregroundColor(.red)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Outfits"),
                    message: Text("Are you sure you want to delete the selected outfits?"),
                    primaryButton: .cancel(Text("Cancel").foregroundColor(.accentColor)),
                    secondaryButton: .destructive(Text("Delete")) {
                        deleteSelectedOutfits()
                    }
                )
                
            }
            .searchable(text: $searchText, prompt: "Search")
        }
        .toolbarBackground(
            .ultraThinMaterial
            ,for: .navigationBar
        )
        .scrollIndicators(.hidden)
        
    }
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func enterSelectMode() {
        isSelectMode = true
    }
    
    func cancelSelection() {
        isSelectMode = false
        selectedOutfits.forEach { outfit in
            outfit.isSelected = false
        }
        selectedOutfits.removeAll()
        selectedOutfit = nil
    }
    
    func deleteSelectedOutfits() {
        selectedOutfits.forEach { outfit in
            closetManager.deleteOutfit(outfit: outfit)
        }
        cancelSelection()
    }
    
    
    func toggleSelection(for outfit: OutfitEntity) {
        outfit.isSelected.toggle()
        
        if outfit.isSelected {
            selectedOutfits.insert(outfit)
        } else {
            selectedOutfits.remove(outfit)
        }
    }
    
    func toggleFavorite(for outfit: OutfitEntity) {
        outfit.isFavorite.toggle()
        CoreDataStack.shared.saveContext()
        
        let feedbackMessage = outfit.isFavorite ? "Added to favorites" : "Removed from favorites"
        let feedbackAlert = UIAlertController(title: nil, message: feedbackMessage, preferredStyle: .alert)
        
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
              rootViewController.present(feedbackAlert, animated: true, completion: nil)
        }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                feedbackAlert.dismiss(animated: true, completion: nil)
                
            }
        }
    }


extension Array where Element == [ClosetItemEntity] {
    func flatten() -> [ClosetItemEntity] {
        return self.flatMap { $0 }
    }
}


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
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

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
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .onAppear {
                    closetManager.getAllItems()
                }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

