//
//  PushNotifications.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 09/08/23.
//
import UserNotifications
import Foundation
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @State private var navigationIsActive = false
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("User granted notification permission")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let scheduleView = ScheduleView(closetManager: ClosetManager())
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
                .environmentObject(ClosetManager())
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: scheduleView))
                window.rootViewController = navigationController
                self.window = window
                window.makeKeyAndVisible()
            }
        }
        
        completionHandler()
    }
}
