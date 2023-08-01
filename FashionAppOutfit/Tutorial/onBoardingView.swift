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
        ["tutorial1", "First, navigate to the Closet and start populating it by tapping on the \"+\" button "],
        ["tutorial2", "Now your job is done, MagicFitter will do the rest, just choose any item"],
        ["tutorial3", "Here you can edit it or add it to laundry, if it's unavailable to wear. If you would like to wear it, press match to generate an outfit around it!"],
        ["tutorial4", "Ta-da!!, MagicFitter made an outfit for you!, if you like it you can save it!, otherwise press try again"],
        ["tutorail5", "Do not which item to choose?, you can simply navigate to Generate, choose style and season (jacket or no jacket)"],
        ["tutorial6", "On Outfits screen, you can see the outfits you saved, you can view them, change the name and add them to favorite by simply pressing one of them"],
        ["tutorial7", "On Laundry screen you can view the unavailable items which will not be used by magicFitter for outfit generation, you can add them back to closet if "],
        ["tutorial8", "You can view this tutorial anytime, but navigating to Tips and pressing the \"i\" button in top right corner "]
    ]
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPageIndex) {
                    ForEach(0..<tutorialData.count, id: \.self) { index in
                        VStack {
                            Image(tutorialData[index][0])
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 200, height: 200)
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
                            
                            if currentPageIndex < tutorialData.count - 1 {
                                Button(action: {
                                    currentPageIndex += 1
                                }) {
                                    Text("Continue")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .frame(width: 175, height: 69, alignment: .center)
                                        .background(Color.gray)
                                        .cornerRadius(20)
                                        .padding()
                                }
                            }
                            else if currentPageIndex == tutorialData.count - 1 {
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


//["tutorial9", "All your app data is securely synced to your iCloud account, do not worry about losing progress!"]
