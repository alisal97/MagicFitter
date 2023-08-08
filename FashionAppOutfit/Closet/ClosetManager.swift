//
//  ClosetItems.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 24/05/23.
//

import Foundation
import UIKit
import CoreData
import SwiftUI

enum ItemType: String {
    case tops
    case bottoms
    case jackets
}

enum ItemStyle: String, CaseIterable {
    case formal
    case casual
    case both
}

struct ClosetItem {
    var name: String
    var color: String
    let itemStyle: ItemStyle
    let itemType: ItemType
    var image: UIImage
    var itemDate = Date()
    var isAvailable = true
    var id = UUID()
}


class ClosetManager: ObservableObject {
    @Published var items: [ClosetItemEntity] = []
    @Published var generatedOutfitItems: [ClosetItemEntity] = []
    @Published var showGeneratedOutfit = false 
    

    let colorCombinations = [
        ["Yellow", "Yellow", "Yellow"],
        ["Yellow", "Green", "Orange"],
        ["Yellow", "Orange", "Orange"],
        ["Yellow", "Violet", "Violet"],
        ["Yellow", "Blue", "Red"],
        ["Green", "Yellow", "Blue"],
        ["Green", "Red", "Red"],
        ["Green", "Violet", "Orange"],
        ["Green", "Violet", "Violet"],
        ["Blue", "Blue", "Blue"],
        ["Blue", "Violet", "Green"],
        ["Blue", "Violet", "Violet"],
        ["Blue", "Yellow", "Red"],
        ["Blue", "Yellow", "Yellow"],
        ["Violet", "Violet", "Violet"],
        ["Violet", "Red", "Pink"],
        ["Violet", "Orange", "Blue"],
        ["Red", "Red", "Red"],
        ["Red", "Orange", "Violet"],
        ["Red", "Violet", "Violet"],
        ["Red", "Green", "Green"],
        ["Red", "Yellow", "Blue"],
        ["Red", "Yellow", "Yellow"],
        ["Pink", "Pink", "Pink"],
        ["Pink", "Red", "Violet"],
        ["Pink", "Light Blue", "Light Blue"],
        ["Pink", "Green", "Green"],
        ["Pink", "Yellow", "Yellow"],
        ["Black", "Black", "Black"],
        ["Black", "Black", "White"],
        ["Black", "Black", "Red"],
        ["Black", "Blue", "Blue"],
        ["Black", "Pink", "Pink"],
        ["Black", "Red", "Red"],
        ["White", "Violet", "Violet"],
        ["White", "White", "White"],
        ["White", "Green", "Green"],
        ["White", "Blue", "Blue"],
        ["White", "Light Blue", "Light Blue"],
        ["Beige", "Beige", "Beige"],
        ["Beige", "Orange", "Orange"],
        ["Beige", "Red", "Red"],
        ["Beige", "Green", "Green"],
        ["Beige", "Yellow", "Yellow"],
        ["Beige", "Blue", "Blue"],
        ["Beige", "Pink", "Pink"],
        ["Beige", "Blue", "Blue"],
        ["Beige", "Violet", "Violet"],
        ["Beige", "Black", "Black"],
        ["Beige", "White", "White"],
        ["Brown", "Yellow", "Yellow"],
        ["Brown", "Orange", "Orange"],
        ["Brown", "Brown", "Brown"],
        ["Brown", "Gray", "Gray"],
        ["Brown", "Yellow", "Orange"],
        ["Brown", "Green", "Green"],
        ["Brown", "Blue", "Blue"],
        ["Brown", "Violet", "Violet"],
        ["Brown", "Red", "Red"],
        ["Brown", "Pink", "Pink"],
        ["Brown", "Black", "Black"],
        ["Brown", "White", "White"],
        ["Denim", "Denim", "Black"],
        ["Denim", "Black", "Black"],
        ["Denim", "Orange", "Orange"],
        ["Denim", "Red", "Red"],
        ["Denim", "Green", "Green"],
        ["Denim", "Yellow", "Yellow"],
        ["Denim", "Pink", "Pink"],
        ["Denim", "Violet", "Violet"],
        ["Denim", "Black", "Black"],
        ["Denim", "White", "White"],
        ["Olive Green", "Black", "Black"],
        ["Olive Green", "Olive Green", "Black"],
        ["Olive Green", "Olive Green", "White"],
        ["Olive Green", "White", "White"],
        ["Olive Green", "Olive Green", "Beige"],
        ["Olive Green", "Beige", "Beige"],
        ["Gray", "Gray", "Gray"],
        ["Gray", "Brown", "Brown"],
        ["Gray", "Yellow", "Yellow"],
        ["Gray", "Green", "Green"],
        ["Gray", "Blue", "Blue"],
        ["Gray", "Violet", "Violet"],
        ["Gray", "Red", "Red"],
        ["Gray", "Pink", "Pink"],
        ["Gray", "Black", "Black"],
        ["Gray", "White", "White"],
        ["Brown", "Yellow", "Yellow"],
    ];
    
    init() {
        getAllItems()
    }
    
    func addItem(name: String, color: String, itemType: ItemType, itemStyle: ItemStyle, image: UIImage, isAvailable: Bool) {
        let context = CoreDataStack.shared.context
        
        let newItem = ClosetItemEntity(context: context)
        newItem.name = name
        newItem.color = color
        newItem.id = UUID()
        newItem.isAvailable = true
        newItem.itemType = itemType.rawValue
        newItem.itemStyle = itemStyle.rawValue
        newItem.itemDate = Date()
        newItem.imageData = image.jpegData(compressionQuality: 69)
        
        CoreDataStack.shared.saveContext()
        getAllItems()
    }

    func deleteItem(id: UUID) {
        if let item = items.first(where: { $0.id == id }) {
            CoreDataStack.shared.context.delete(item)
            CoreDataStack.shared.saveContext()
            getAllItems()
        }
    }

    func editItem(id: UUID, itemType: ItemType, itemStyle: ItemStyle, newName: String, newColor: String, newImage: UIImage?) {
        if let item = items.first(where: { $0.id == id }) {
            item.itemType = itemType.rawValue
            item.itemStyle = itemStyle.rawValue
            item.name = newName
            item.color = newColor
            
            if let newImage = newImage {
                item.imageData = newImage.jpegData(compressionQuality: 69)
            }
            
            CoreDataStack.shared.saveContext()
            getAllItems()
        }
    }

    func getAllItems() {
        let fetchRequest: NSFetchRequest<ClosetItemEntity> = ClosetItemEntity.fetchRequest()
        
        do {
            self.items = try CoreDataStack.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func fetchItems(completion: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<ClosetItemEntity> = ClosetItemEntity.fetchRequest()
        
        do {
            self.items = try CoreDataStack.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }

    func generatedOutfitItems(chosenItem: ClosetItemEntity, includeJacket: Bool) {
        generatedOutfitItems = []
        
        if let matchingOutfit = generateMatchingOutfit(chosenItem: chosenItem, itemStyle: ItemStyle(rawValue: chosenItem.itemStyle ?? "") ?? .both, includeJacket: includeJacket) {
            if matchingOutfit.isEmpty {
                print("No outfit generated.")
            } else {
                let outfitItems = Array(matchingOutfit.values)
                generatedOutfitItems = outfitItems
                showGeneratedOutfit = true
            }
        }
    }
    public func generateMatchingOutfit(chosenItem: ClosetItemEntity, itemStyle: ItemStyle, includeJacket: Bool) -> [String: ClosetItemEntity]? {
        guard let itemType = chosenItem.itemType, let color = chosenItem.color else {
            return nil
        }
        
        var matchingOutfit: [String: ClosetItemEntity] = [:]
        
        var remainingItemTypes: [String] = ["tops", "bottoms"].filter { $0 != itemType }

        if includeJacket {
            remainingItemTypes.append("jackets")
        }
        
        var matchingStyles: [ItemStyle] = []
        
        if itemStyle == .both {
            matchingStyles = [.casual, .formal, .both]
        } else if itemStyle == .casual {
            matchingStyles = [.casual, .both]
        } else if itemStyle == .formal {
        matchingStyles = [.formal, .both]
        } else {
            matchingStyles = [itemStyle]
        }
        
        let shuffledCombinations = colorCombinations.shuffled()

        for combination in shuffledCombinations {
            if combination.contains(color) {
                for itemType in remainingItemTypes {
                    let matchingItems = items.filter { item in
                        guard let itemStyle = ItemStyle(rawValue: item.itemStyle ?? "") else {
                            return false
                        }
                        return item.itemType == itemType && combination.contains(item.color ?? "") && item.isAvailable && matchingStyles.contains(itemStyle)
                    }

                    if matchingItems.count >= 1 {
                        let matchingItem = matchingItems.randomElement()!
                        matchingOutfit[itemType] = matchingItem
                    } else {
                        matchingOutfit = [:] // Reset the outfit if a matching item is not found
                        break
                    }
                }
                
                matchingOutfit[itemType] = chosenItem
                
                if includeJacket {
                    if matchingOutfit.count == 3 {
                        return matchingOutfit
                    }
                }
                if !includeJacket {
                    if matchingOutfit.count == 2 {
                        return matchingOutfit
                    }
                }
            }
        }

        return nil
    }

    
    func saveOutfit(outfitItems: [ClosetItemEntity]) {
        let context = CoreDataStack.shared.context

        let newOutfit = OutfitEntity(context: context)
        let outfitDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let outfitTime = dateFormatter.string(from: outfitDate)
        
        let outfitName = "Outfit \(outfitTime)"
        newOutfit.outfitName = outfitName
        newOutfit.outfitID = UUID()
        
        newOutfit.date = outfitDate
        newOutfit.isFavorite = false // Set as non-favorite by default
        
        if let outfitPhoto = generateOutfitPhoto(outfitItems: outfitItems) {
            newOutfit.outfitPic = outfitPhoto.jpegData(compressionQuality: 1.0)
        }
        
        for item in outfitItems {
            newOutfit.addToItems(item)
        }
        
        CoreDataStack.shared.saveContext()
    }

    func addToFavorites(outfit: OutfitEntity) {
        outfit.isFavorite = true // Set the outfit as a favorite
        CoreDataStack.shared.saveContext()
    }

    func generateOutfitPhoto(outfitItems: [ClosetItemEntity]) -> UIImage? {
        let itemImages = outfitItems.compactMap { $0.imageData }
        guard !itemImages.isEmpty else {
            return nil
        }
        
        let frameSize = CGSize(width: 335, height: 370)
        let canvasSize = frameSize
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let combinedImage = renderer.image { context in
            var xPos: CGFloat = 0
            let itemWidth = frameSize.width / CGFloat(outfitItems.count)
            
            for imageData in itemImages {
                if let itemImage = UIImage(data: imageData) {
                    let scaledImageSize = CGSize(width: itemWidth, height: frameSize.height)
                    let scaledImageRect = CGRect(origin: CGPoint(x: xPos, y: 0), size: scaledImageSize)
                    itemImage.draw(in: scaledImageRect)
                    xPos += itemWidth
                }
            }
        }
        
        // Scale the combined image to the desired frame size
        let scaledImage = combinedImage.resize(toSize: frameSize)
        
        return scaledImage
    }

    func deleteOutfit(outfit: OutfitEntity) {
        let context = CoreDataStack.shared.context
        context.delete(outfit)
        CoreDataStack.shared.saveContext()
        
    }
    func deleteScheduledOutfit(outfit: OutfitScheduler) {
        let context = CoreDataStack.shared.context
        
        context.delete(outfit)
        
        do {
            try context.save()
        } catch {
            print("Error deleting scheduled outfit: \(error)")
        }
    }
    func deleteOutdatedScheduledOutfits() {
        let context = CoreDataStack.shared.context
        
        let fetchRequest: NSFetchRequest<OutfitScheduler> = OutfitScheduler.fetchRequest()
        let currentDate = Date()
        let calendar = Calendar.current
        let twentyFourHoursAgo = calendar.date(byAdding: .hour, value: -24, to: currentDate)!

        fetchRequest.predicate = NSPredicate(format: "scheduleDate < %@", twentyFourHoursAgo as NSDate)

        do {
            let outdatedOutfits = try context.fetch(fetchRequest)
            for outfit in outdatedOutfits {
                context.delete(outfit)
            }
            
            try context.save()
        } catch {
            print("Error deleting outdated scheduled outfits: \(error)")
        }
    }


}

extension UIImage {
    func resize(toSize size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let resizedImage = renderer.image { context in
            draw(in: CGRect(origin: .zero, size: size))
        }
        
        return resizedImage
    }
}
