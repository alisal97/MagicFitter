//
//  outfitView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 01/06/23.
//

import SwiftUI
import CoreData

struct GeneratedOutfitView: View {
    var outfitItems: [ClosetItemEntity]
    @EnvironmentObject var closetManager: ClosetManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isSaved = false
    @State var generatedOutfitItems: [ClosetItemEntity] = []
    @State private var includeJacket: Bool
    let item: ClosetItemEntity
    
    init(outfitItems: [ClosetItemEntity], item: ClosetItemEntity) {
        self.outfitItems = outfitItems
        self.item = item
        self._includeJacket = State(initialValue: true) // Initialize includeJacket state
    }


    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(width: 250, height: 4)
                    .cornerRadius(2)
                    .padding()
            }
            Spacer()
            Text("Outfit Generated Successfully!")
                .font(.title3)
                .foregroundColor(.accentColor)
            List {
                ForEach(outfitItems, id: \.id) { item in
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
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                                
                            }
                        }
                        ItemLabel(title: "Type", value: item.itemType ?? "")
                        ItemLabel(title: "Style", value: item.itemStyle ?? "")
                        
                        
                    }
                }
            }
            .listStyle(.plain)
    Spacer()
            VStack {
                Button(action: {
                    saveOutfit()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) { [self] in
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    VStack {
                        Text(isSaved ? "Outfit Saved" : "Save Outfit")
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.gray.opacity(0.35))
                            .cornerRadius(12)
                    }
                    .padding(.top, 35)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8) // Reduce the bottom padding of the "Save" button
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text("Try Again!")
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, 0) // Reduce the trailing padding of the text
                        
                        Image(systemName: "arrow.clockwise.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.35))
                    .cornerRadius(12)
                    .padding(.bottom, 35)
                    .padding(.horizontal, 100)
                }
            }

            .padding(.top, 23)
        }
        .onAppear {
            closetManager.getAllItems()
        }
    }
    

    func saveOutfit() {
        if !isSaved { // Check if the outfit is already saved
            closetManager.saveOutfit(outfitItems: outfitItems)
            isSaved = true // Mark the outfit as saved to prevent duplicate saves
        }
    }
    
}
