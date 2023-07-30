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
            Text("Your outfit is ready!")
                .font(.title2)
                .foregroundColor(.accentColor)
                .padding(.bottom, 35)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(outfitItems, id: \.id) { item in
                    ZStack(alignment: .bottom) {
                        Image(uiImage: UIImage(data: item.imageData!)!)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 169, height: 169)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                        
                        
                        if let name = item.name {
                            Text(name)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.69))
                                .cornerRadius(8)
                                .offset(y: 1)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )

                }
            }
            .padding(.horizontal)
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
