//
//  TipsView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/07/23.
//

import SwiftUI
import UIKit
import CoreData

struct TipsView: View {
    let tipsTexts = [
        ["tips1", "Embrace simplicity in your style choices. Avoid excessive accessories or loud patterns. Opt for clean lines, solid colors, and timeless pieces that can be effortlessly mixed and matched"],
        ["tips2", "Quality fabrics and well-made garments instantly elevate your look. Invest in well-fitted, durable, and classic pieces that will stand the test of time"],
        ["tips3", "Ensure your clothes fit perfectly. Tailoring can make a significant difference in how you present yourself and can elevate even simple outfits to a more refined level."],
        ["tips4", "Don't be afraid to step out of your comfort zone and try new styles. You might discover unexpected combinations that suit you well."],
        ["tips5", "When in doubt, go for socks that match the color of your trousers or pants. This creates a seamless and elongated look, especially when wearing dressier outfits"],
        ["tips6", "If you wear multiple pieces of jewelry, like rings, bracelets, and necklaces, aim to keep the metals consistent. This creates a harmonious look and prevents your accessories from clashing."],
        ["tips7", "Invest in a collection of neutral-colored basics like plain t-shirts, well-fitted jeans, and classic button-up shirts. These versatile pieces can form the foundation for countless outfits."]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                TabView {
                    ForEach(tipsTexts, id: \.self) { tipData in
                        VStack {
                            Image(tipData[0])
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)    
                                .frame(width: 375, height: 450)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    GeometryReader { geo in
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(Color.black.opacity(0.5))
                                                .cornerRadius(10)
                                            
                                            Text(tipData[1])
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                                .font(.system(size: 25))
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(nil)
                                        }
                                        .padding(8)
                                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                                    }
                                )
                        }
                        .background(Color.clear)
                        .cornerRadius(10)
                        .frame(width: 375, height: 450)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                Spacer().frame(height: 15)
            }
            .padding(.bottom, 27)
            .navigationTitle("Tips")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button(action: {

            }) {
                Image(systemName: "info.circle")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                    .background(Color.gray)
                    .cornerRadius(20)
            })
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .scrollIndicators(.hidden)
        }
    }
}
#Preview {
    TipsView()
}
