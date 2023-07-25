//
//  savedOutfitView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 05/06/23.
//

import SwiftUI
import UIKit


struct SavedOutfitView: View {
    let outfit: OutfitEntity
    @EnvironmentObject var closetManager: ClosetManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite = false // Track the favorite state
    @State private var showDeleteConfirmation = false // Track whether the delete confirmation should be shown
    @State private var isEditingOutfitName = false // Track whether the outfit name is being edited
    @State private var editedOutfitName = "" // Track the edited outfit name
    
    @State private var selectedItem: ClosetItemEntity? = nil

    var body: some View {
        NavigationView {
            VStack {
                 HStack {
                    if isEditingOutfitName {
                        TextField("Outfit Name", text: $editedOutfitName, onCommit: {
                            endEditingOutfitName()
                        })
                        .padding(.leading)
                        .cornerRadius(8)
                        .font(.title2)
                        .frame(width: 300, height: 35, alignment: .topLeading)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .background(Color.gray.opacity(0.35), in: Capsule()).frame(minWidth:200 , maxWidth:200, alignment: .leading)
                    } else {
                        ZStack {
                            Text(outfit.outfitName ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.leading)
                                .frame(width: 300, height: 35, alignment: .topLeading)
                            ZStack(alignment: .trailing) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                                    .font(.title2)
                            }
                                .padding(.leading, 210)
                        }
                        .background(Color.gray.opacity(0.35), in: Capsule()).frame(minWidth:200 , maxWidth:200, alignment: .leading)
                        .onTapGesture {
                            startEditingOutfitName()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isFavorite.toggle()
                        updateFavoriteStatus()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .accentColor)
                            .font(.title)
                    }
                    .padding()
                }

                
                List(outfit.closetItemArray, id: \.id) { item in
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
                    .onTapGesture {
                        endEditingOutfitName()
                        selectedItem = item // Set the selected item
                    }
                    .sheet(item: $selectedItem) { selectedItem in
                        FullView(item: selectedItem, closetManager: closetManager)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        showDeleteConfirmation = true // Show the delete confirmation alert
                    }) {
                        Text("Delete outfit")
                            .foregroundColor(.red)
                            .frame(maxWidth: 175)
                            .padding()
                            .background(Color.gray.opacity(0.35))
                            .cornerRadius(12)
                    }
                }
                
                Spacer(minLength: 25)
            }
            .ignoresSafeArea(.keyboard)
            .listStyle(.plain)
            .onAppear {
                isFavorite = outfit.isFavorite
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Outfit"),
                message: Text("Are you sure you want to delete this outfit?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    deleteOutfit()
                }
            )
        }
    }
    
    func deleteOutfit() {
        presentationMode.wrappedValue.dismiss()
        closetManager.deleteOutfit(outfit: outfit)
    }
    
    func startEditingOutfitName() {
        isEditingOutfitName = true
        editedOutfitName = outfit.outfitName ?? ""
    }
    
    func endEditingOutfitName() {
        isEditingOutfitName = false
        outfit.outfitName = editedOutfitName
        CoreDataStack.shared.saveContext()
    }
    
    func updateFavoriteStatus() {
        outfit.isFavorite = isFavorite // Update the favorite status
        CoreDataStack.shared.saveContext()
        
        
        
        let feedbackMessage = outfit.isFavorite ? "Added to favorites" : "Removed from favorites"
        let feedbackAlert = UIAlertController(title: nil, message: feedbackMessage, preferredStyle: .alert)
        feedbackAlert.modalPresentationStyle = .overFullScreen

        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
              rootViewController.present(feedbackAlert, animated: true, completion: nil)
        }


            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                feedbackAlert.dismiss(animated: true, completion: nil)
                
            }
        }

    }

struct ItemLabel: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            getImageForTitle(title)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
            
            Text("\(title):")
                .font(.headline)
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.accentColor)
                .fontWeight(.regular)
        }
    }
    
    func getImageForTitle(_ title: String) -> Image {
        switch title {
        case "Name":
            return Image(systemName: "tag")
        case "Color":
            return Image(systemName: "eyedropper")
        case "Type":
            return Image(systemName: "tag.fill")
        case "Style":
            return Image(systemName: "wand.and.rays")
        default:
            return Image(systemName: "questionmark")
        }
    }
}

extension OutfitEntity {
    var closetItemArray: [ClosetItemEntity] {
        let set = items as? Set<ClosetItemEntity> ?? []
        return set.sorted { $0.name ?? "" < $1.name ?? "" }
    }
}
