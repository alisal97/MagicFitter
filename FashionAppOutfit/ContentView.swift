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
    
    let closetManager = ClosetManager() // Create an instance of ClosetManager
    @Environment(\.colorScheme) var colorScheme // Access the color scheme
    var body: some View {
        TabView {
            
            WardrobeView(closetManager: closetManager) // Pass the closetManager to WardrobeView
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Wardrobe")
                    
                }
            
            
            outfitsView(closetManager: closetManager) // Pass the closetManager to HistoryView
                .tabItem {
                    Image(systemName: "bookmark.circle")
                    Text("Outfits")
                }

            
        }
        .accentColor(colorScheme == .dark ? Color.white : Color.black)
        .background(colorScheme == .dark ? Color.black : Color.white)
        

    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

