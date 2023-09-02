//
//  savedOutfitView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 05/06/23.
//

import SwiftUI
import UIKit
import Photos

struct SavedOutfitView: View {
    let outfit: OutfitEntity
    @EnvironmentObject var closetManager: ClosetManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite = false
    @State private var showDeleteConfirmation = false
    @State private var isEditingOutfitName = false
    @State private var editedOutfitName = "" 
    
    @State private var selectedItem: ClosetItemEntity? = nil
    
    @State private var image: Image? = nil
    
    var body: some View {
        NavigationStack {
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

                        VStack(alignment: .leading, spacing: 8 ) {
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
                    .onTapGesture {
                        endEditingOutfitName()
                        selectedItem = item // Set the selected item
                    }
                    .sheet(item: $selectedItem) { selectedItem in
                        FullView(item: selectedItem, closetManager: closetManager)
                    }
                }
    
                HStack {
                    ShareLink(
                        item: image ?? Image("FallbackImage"),
                        preview: SharePreview(
                            "Share \(outfit.outfitName ?? "") ",
                            image: image ?? Image("FallbackImage")
                        )
                    ) {
                            Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.accentColor)
                            .font(.title)
                            .frame(alignment: .leading)
                    }
                    .padding(25)

                    Spacer()
                    
                    Button(action: {
                        showDeleteConfirmation = true
                        
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.title)
                            .foregroundColor(.red)
                            .frame(alignment: .trailing)
                            .padding(25)
                        
                    }
                    
                }
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .listStyle(.automatic)
            .onAppear {
                isFavorite = outfit.isFavorite
                captureSnapshot()
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
    
    func captureSnapshot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0 is UIWindowScene }) as? UIWindowScene,
               let uiImage = windowScene.windows.first?.screenshot() {
                self.image = Image(uiImage: uiImage)
            }
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

extension UIWindow {
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.nativeScale)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIView {
    func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.nativeScale)
        defer { UIGraphicsEndImageContext() }
        layer.render(in: UIGraphicsGetCurrentContext()!)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

extension OutfitEntity {
    var closetItemArray: [ClosetItemEntity] {
        let set = items as? Set<ClosetItemEntity> ?? []
        return set.sorted { $0.name ?? "" < $1.name ?? "" }
    }
}
