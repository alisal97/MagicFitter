//
//  contentHelpers.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 03/06/23.
//

import SwiftUI
import UIKit


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
            return Image(systemName: "sparkle")
        default:
            return Image(systemName: "questionmark")
        }
    }
}

extension Array where Element == [ClosetItemEntity] {
    func flatten() -> [ClosetItemEntity] {
        return self.flatMap { $0 }
    }
}


//not used anymore
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
                                .offset(y: 3) 
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .buttonStyle(PlainButtonStyle())
                }
            }
        )
        .frame(width: 135, height: 135)
        .background(Color.clear)
        .cornerRadius(8)
    }
}



struct FloatingButton: View {
    let action: () -> Void
    let icon: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.title.weight(.semibold))
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.gray)
                .clipShape(Circle())
                .shadow(radius: 10)
                .offset(x: -19, y: -19)
            }
        }
    }
}

