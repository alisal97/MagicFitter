//
//  SceneDelegate.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 09/08/23.
//

import Foundation
import SwiftUI
import UserNotifications
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let contentView = ContentView(item: ClosetItemEntity())
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
                .environmentObject(ClosetManager())
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.never)
                .onAppear {
                    ClosetManager().getAllItems()
                }

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

}

