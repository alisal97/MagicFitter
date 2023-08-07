//
//  onBoardingView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 31/07/23.1
//

import Foundation
import SwiftUI

struct onBoardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPageIndex = 0

    let tutorialData = [
        ["tutorial0", ""],
        ["tutorial1", "To start, head to the Closet and populate it by tapping on the \"+\" button. Repeat until you have a variety of items and colors!"],
        ["tutorial2", "After populating your closet, the hard part is done, MagicFitter will take care of the rest, just tap any item!"],
        ["tutorial3", "Here you can edit it or add it to the laundry if it's not available to wear. Or Tap \"match\" to use it to generate an outfit!"],
        ["tutorial4", "Voila! MagicFitter has created an outfit for you! If you like it, save it. If not, simply press \"try again!\""],
        ["tutorial5", "If you're unsure about which item to wear, head to Generate, select a style and season (summer means no jacket) and tap \"Generate Outfit!\""],
        ["tutorial6", "On the Outfits screen, you can find the outfits you've saved. By tapping one, you can view the items, change outfit name, and add it to your favorites!"],
        ["tutorial7", "The Laundry screen displays unavailable items that MagicFitter won't use for outfit generation. If they're ready to wear again, you can add them back to your closet!"],
        ["tutorial8", "You can access this tutorial anytime by going to Tips and pressing the \"i\" button in the top-right corner!"]
    ];




    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPageIndex) {
                    ForEach(0..<tutorialData.count, id: \.self) { index in
                        VStack {
                            if tutorialData[index][0] == "tutorial0" {
                                Spacer()
                                Text("""
                                        Welcome to MagicFitter!, MagicFitter is an automatic outfit generator that creates outfits for you based on colors, using clothing items you already own!. Your app data is securely synced to your iCloud account, ensuring you never lose progress. Let's get started!
                                        """)
                                    .foregroundStyle(Color.accentColor)
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                    .padding(.top, 47)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                            }
                            else {
                                Image(tutorialData[index][0])
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.bottom, 5)
                            }
                            Text(tutorialData[index][1])
                                .foregroundColor(.accentColor)
                                .font(.headline)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.center)
                                .padding()
                                .lineLimit(nil)
                            
                            Spacer()
                            
                            Button(action: {
                                if currentPageIndex < tutorialData.count - 1 {
                                    currentPageIndex += 1
                                } else {
                                    showOnboarding = false
                                }
                            }) {
                                Text(currentPageIndex < tutorialData.count - 1 ? "Continue" : "I am ready")
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 135, height: 43, alignment: .center)
                                    .background(Color.gray)
                                    .cornerRadius(20)
                            }
                            .padding(.bottom, 23)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.clear)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

            }
            .padding(.top, 20)
        }
    }
}




