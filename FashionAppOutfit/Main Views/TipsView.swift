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
        ["tips1", "Tip 1: Lorem ipsum dolor sit amet, consectetur adipiscing elit."],
        ["tips2", "Tip 2: Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."],
        ["tips3", "Tip 3: Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."],
        ["tips4", "Tip 4: Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore."],
        ["tips5", "Tip 5: Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia."],
        ["tips6", "If you wear multiple pieces of jewelry, like rings, bracelets, and necklaces, aim to keep the metals consistent, for example, silver with silver, gold with gold..so on. This creates a harmonious look and prevents your accessories from clashing."],
        ["tips7", "Tip 7: Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                TabView {
                    ForEach(tipsTexts, id: \.self) { tipData in
                        VStack {
                            Spacer()
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
                                                .foregroundColor(Color.black.opacity(0.45))
                                                .cornerRadius(10)
                                            
                                            Text(tipData[1])
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                                .font(.title3)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(nil)
                                                .opacity(0.75)
                                        }
                                        .padding(8)
                                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                                    }
                                )
                            Spacer()
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
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
            }
            .padding(.vertical, 50)
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
