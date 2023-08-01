//
//  CoreDataStack.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 24/05/23.
//

import Foundation
import CoreData
import CloudKit

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "dataModel")
        
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processCloudKitChanges(_:)), name: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator)
        
        try? container.viewContext.setQueryGenerationFrom(.current)
        
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle save error
                print("Failed to save context: \(error)")
            }
        }
    }
    
    @objc func processCloudKitChanges(_ notification: NSNotification) {
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
}
