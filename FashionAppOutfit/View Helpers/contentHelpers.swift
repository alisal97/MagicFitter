//
//  contentHelpers.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 03/06/23.
//

import SwiftUI
import UIKit

// Helper view to present the UIImagePickerController
struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias SourceType = UIImagePickerController.SourceType
    
    let sourceType: SourceType
    let completionHandler: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completionHandler: completionHandler)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need to update the view controller
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completionHandler: (UIImage?) -> Void
        
        init(completionHandler: @escaping (UIImage?) -> Void) {
            self.completionHandler = completionHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            picker.dismiss(animated: true, completion: nil)
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


struct SectionView: View {
    let title: String
    let items: [ClosetItemEntity]
    let closetManager: ClosetManager 

    var body: some View {
        
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .bold()
                .padding(.vertical)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items, id: \.id) { item in
                        CardView(item: item, closetManager: closetManager)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CardView: View {
    let item: ClosetItemEntity
    @State private var isShowingFullView = false // Track whether the full view is shown
    @ObservedObject var closetManager: ClosetManager

    var body: some View {
        NavigationLink(
            destination: FullView(item: item, closetManager: closetManager),
            label: {
                if let imageData = item.imageData, let image = UIImage(data: imageData) {
                    ZStack(alignment: .bottom) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135, height: 135)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        if let name = item.name {
                            Text(name)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.69)) //nice
                                .cornerRadius(8)
                                .offset(y: 3) // Adjust the vertical position here
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .buttonStyle(PlainButtonStyle()) // Remove the default button style
                }
            }
        )
        .frame(width: 135, height: 135)
        .background(Color.clear)
        .cornerRadius(8)
    }
}
