//
//  onBoardingView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 31/07/23.
//

import Foundation
import SwiftUI

struct onBoardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPageIndex = 0
    
    let tutorialData = [
        ["tutorial1", "First, navigate to the closet and start populating it"],
        ["tutorial2", "Quality fabrics and well-made garments instantly elevate your look. Invest in well-fitted, durable, and classic pieces that will stand the test of time"],
        ["tutorial3", "Ensure your clothes fit perfectly. Tailoring can make a significant difference in how you present yourself and can elevate even simple outfits to a more refined level."],
        ["tutorial4", "Don't be afraid to step out of your comfort zone and try new styles. You might discover unexpected combinations that suit you well."],
        ["tutorail5", "When in doubt, go for socks that match the color of your trousers or pants. This creates a seamless and elongated look, especially when wearing dressier outfits"],
        ["tutorial6", "If you wear multiple pieces of jewelry, like rings, bracelets, and necklaces, aim to keep the metals consistent. This creates a harmonious look and prevents your accessories from clashing."],
        ["tutorial7", "Invest in a collection of neutral-colored basics like plain t-shirts, well-fitted jeans, and classic button-up shirts. These versatile pieces can form the foundation for countless outfits."]
    ]
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPageIndex) {
                    ForEach(0..<tutorialData.count, id: \.self) { index in
                        VStack {
                            Image(tutorialData[index][0])
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.vertical, 50)
                            
                            Text(tutorialData[index][1])
                                .foregroundColor(.accentColor)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                            
                            if currentPageIndex == tutorialData.count - 1 {
                                Button(action: {
                                    showOnboarding = false
                                }) {
                                    Text("I am ready")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .frame(width: 175, height: 69, alignment: .center)
                                        .background(Color.gray)
                                        .cornerRadius(20)
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                        .background(Color.clear)
                        .cornerRadius(10)
                        .frame(width: 300, height: 300)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
            }
        }
    }
}

#Preview {
    onBoardingView(showOnboarding: .constant(true))
}
