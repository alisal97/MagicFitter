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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @Environment(\.scenePhase) var scenePhase
    @State var selectedItem: ClosetItemEntity?
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                onBoardingView(showOnboarding: $isFirstLaunch)
                    .ignoresSafeArea(.all)
            } else {
                ContentView(item: ClosetItemEntity(), selectedItem: $selectedItem )
                    .environment(\.managedObjectContext, CoreDataStack.shared.context)
                    .environmentObject(ClosetManager())
                    .scrollDismissesKeyboard(.immediately)
                    .scrollIndicators(.never)
                    .onAppear {
                        ClosetManager().getAllItems()
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .background {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        }
                    }
            }
        }
        
    }
}
