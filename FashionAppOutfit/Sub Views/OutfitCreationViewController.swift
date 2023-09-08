//
//  OutfitCreationViewController.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 08/09/23.
//
import SwiftUI


struct OutfitCreationViewController: View {
    @ObservedObject var closetManager: ClosetManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedJacket: ClosetItemEntity?
    @State private var selectedTops: ClosetItemEntity?
    @State private var selectedBottoms: ClosetItemEntity?
    @State private var outfitName = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Outfit Name", text: $outfitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                VStack(alignment: .leading) {
                    // Picker for Jacket / Coat
                    Picker("Select a Jacket / Coat", selection: $selectedJacket) {
                        Text("None").tag(nil as ClosetItemEntity?)
                        ForEach(closetManager.items.filter { $0.itemType == ItemType.jackets.rawValue }, id: \.self) { item in
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 55, height: 55)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.accentColor, lineWidth: 2)
                                        )
                                }
                                Text(item.name ?? "")
                            }
                            .tag(item)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Picker for Top
                    Picker("Select a Top", selection: $selectedTops) {
                        Text("None").tag(nil as ClosetItemEntity?)
                        ForEach(closetManager.items.filter { $0.itemType == ItemType.tops.rawValue }, id: \.self) { item in
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 55, height: 55)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.accentColor, lineWidth: 2)
                                        )
                                }
                                Text(item.name ?? "")
                            }
                            .tag(item)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Picker for Bottom
                    Picker("Select a Bottom", selection: $selectedBottoms) {
                        Text("None").tag(nil as ClosetItemEntity?)
                        ForEach(closetManager.items.filter { $0.itemType == ItemType.bottoms.rawValue }, id: \.self) { item in
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 55, height: 55)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.accentColor, lineWidth: 2)
                                        )
                                }
                                Text(item.name ?? "")
                            }
                            .tag(item)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Button("Save Outfit") {
                    createOutfit()
                }
                .frame(maxWidth: 150, alignment: .center)
                .padding()
                .fontWeight(.bold)
                .background(Color.gray.opacity(0.35))
                .cornerRadius(12)
                .disabled(selectedTops == nil || selectedBottoms == nil)
            }
            .navigationBarTitle("Create Outfit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func createOutfit() {
        guard let selectedTops = selectedTops, let selectedBottoms = selectedBottoms else {
            return
        }

        var selectedItems: [ClosetItemEntity] = [selectedTops, selectedBottoms]
        if let selectedJacket = selectedJacket {
            selectedItems.append(selectedJacket)
        }

        closetManager.createOutfitWithItems(items: selectedItems)

        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    OutfitCreationViewController(closetManager: ClosetManager())
}
