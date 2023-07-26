//
//  ContentView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 23/05/23.
//

import SwiftUI
import UIKit
import CoreData

struct ContentView: View {
    
    let closetManager = ClosetManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var selection = 3
    let item: ClosetItemEntity
    
    var body: some View {
        TabView(selection:$selection) {
            LaundryView(closetManager: closetManager)
                .tabItem {
                    Image(systemName: "washer.fill")
                    Text("Laundry")
                }
                .tag(1)

            ClosetView(closetManager: closetManager)
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Closet")
                }
                .tag(2)

            GenerateView(item: item, closetManager: closetManager)
                .tabItem {
                    Image(systemName: "wand.and.stars.inverse")
                    Text("Generate")
                }
                .tag(3)
            
            OutfitsView(closetManager: closetManager)
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Outfits")
                }
                .tag(4)

            TipsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Tips")
                }
                .tag(5)
        }
        .accentColor(colorScheme == .dark ? Color.white : Color.black)
        .background(colorScheme == .dark ? Color.black : Color.white)
        

    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(item: ClosetItemEntity())
    }
}

