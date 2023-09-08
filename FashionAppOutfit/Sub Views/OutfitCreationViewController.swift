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
        NavigationView {
            VStack {
                TextField("Outfit Name", text: $outfitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                VStack(alignment: .leading) {
                    ItemSelectionRow(title: "Select a Jacket / Coat", selectedItem: $selectedJacket, itemType: .jackets, closetManager: closetManager)
                    ItemSelectionRow(title: "Select a Top", selectedItem: $selectedTops, itemType: .tops, closetManager: closetManager)
                    ItemSelectionRow(title: "Select a Bottom", selectedItem: $selectedBottoms, itemType: .bottoms, closetManager: closetManager)
                }
                .frame(alignment: .leading)
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

struct ItemSelectionRow: View {
    let title: String
    @Binding var selectedItem: ClosetItemEntity?
    let itemType: ItemType
    @ObservedObject var closetManager: ClosetManager

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            
            Picker("", selection: $selectedItem) {
                Text("None").tag(nil as ClosetItemEntity?)
                ForEach(closetManager.items.filter { $0.itemType == itemType.rawValue }, id: \.self) { item in
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
            .onChange(of: selectedItem) { newValue in
                if newValue != nil {
                    selectedItem = newValue
                }
            }
        }
    }
}

#Preview {
    OutfitCreationViewController(closetManager: ClosetManager())
}
