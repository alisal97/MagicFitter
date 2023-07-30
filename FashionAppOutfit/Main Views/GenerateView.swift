//
//  GenerateView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/07/23.
//

import SwiftUI
import UIKit
import CoreData

struct GenerateView: View {
    let item: ClosetItemEntity
    @ObservedObject var closetManager: ClosetManager
    @State private var includeJacket = true
    @State private var selectedStyle: ItemStyle = .casual
    @State var generatedOutfitItems: [ClosetItemEntity] = []
    @State private var showFeedback = false
    @State var showGeneratedOutfit = false
    @State private var showModal = false 
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if showFeedback {
                    Text("No matching items found for the selected style")
                    
                        .foregroundColor(.red)
                        .font(.headline)
                }
                Spacer()
                
                Button(action: {
                    generatedOutfitItems(includeJacket: includeJacket)
                    if !generatedOutfitItems.isEmpty {
                        showGeneratedOutfit = true
                        
                    } else if generatedOutfitItems.isEmpty {
                        showFeedback = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showFeedback = false
                            }
                        }
                    }
                })
                {
                    VStack {
                        Image(systemName: "wand.and.stars.inverse")
                            .font(.system(size: 65))
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 10)
                        Text("Generate Outfit")
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                }
                
                Picker("Style", selection: $selectedStyle) {
                    Text("Casual").tag(ItemStyle.casual)
                    Text("Formal").tag(ItemStyle.formal)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker(selection: $includeJacket, label: Text("Include Jacket")) {
                    Text("Summer").tag(false)
                    Text("Winter").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(.accentColor)
                Spacer()
                
                
            }
            .padding()
            .sheet(isPresented: $showGeneratedOutfit) {
                GeneratedOutfitView(outfitItems: generatedOutfitItems, item: item)
                    .onAppear {
                        closetManager.getAllItems()
                    }
            }
            .navigationTitle("Generate Outfit")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                Button(action: {
                    showModal = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 21, weight: .semibold))
                        .padding(15)
                }
            )
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .scrollIndicators(.hidden)

            .sheet(isPresented: $showModal) {
                AddItemView(closetManager: closetManager)
            }

        }
    }
    func generatedOutfitItems(includeJacket: Bool) {
        generatedOutfitItems = []

        var chosenItem: ClosetItemEntity?
        if selectedStyle == .casual {
            chosenItem = closetManager.getRandomItem(ofStyle: .casual)
        } else if selectedStyle == .formal {
            chosenItem = closetManager.getRandomItem(ofStyle: .formal)
        } 

        if let chosenItem = chosenItem {
            if let matchingOutfit = closetManager.generateMatchingOutfit(chosenItem: chosenItem, itemStyle: ItemStyle(rawValue: chosenItem.itemStyle!) ?? .casual, includeJacket: includeJacket) {
                if matchingOutfit.isEmpty {
                    print("No outfit generated.")
                } else {
                    let outfitItems = Array(matchingOutfit.values)
                    generatedOutfitItems = outfitItems
                    showGeneratedOutfit = true
                }
            }
        } else {
            print("No matching item found for the selected style.")
        }
    }

}

extension ClosetManager {
    func getRandomItem(ofStyle style: ItemStyle) -> ClosetItemEntity? {
        let matchingItems = items.filter { $0.itemStyle == style.rawValue && $0.isAvailable }
        return matchingItems.randomElement()
    }
}


#Preview {
    GenerateView(item: ClosetItemEntity() , closetManager: ClosetManager())
}
