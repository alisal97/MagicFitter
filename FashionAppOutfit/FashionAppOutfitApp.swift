//
//  FashionAppOutfitApp.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 23/05/23.
//

import SwiftUI
import CoreData

@main
struct FashionAppOutfitApp: App {
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    var body: some Scene {
        WindowGroup {
                    ContentView(item: ClosetItemEntity())
                        .environment(\.managedObjectContext, CoreDataStack.shared.context)
                        .environmentObject(ClosetManager())
                        .scrollDismissesKeyboard(.immediately)
                        .scrollIndicators(.never)
        }
    }
}
