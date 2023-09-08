//
//  ScheduleViewController.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 07/08/23.
//

import SwiftUI
import CoreData

struct ScheduleViewController: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var scheduleDate = Date()
    @State private var title = ""
    @ObservedObject var closetManager: ClosetManager
    @State private var remindMeBefore: Double = 0
    
    @FetchRequest(entity: OutfitEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \OutfitEntity.date, ascending: false)])
    var allOutfits: FetchedResults<OutfitEntity>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scheduling Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Remind me before", selection: $remindMeBefore) {
                        Text("None").tag(Double(0))
                        Text("1 hour").tag(Double(60 * 60))
                        Text("6 hours").tag(Double(8 * 60 * 60))
                        Text("12 hours").tag(Double(12 * 60 * 60))
                        Text("24 hours").tag(Double(24 * 60 * 60))
                    }
                    .pickerStyle(.menu)
                }
                    Section(header: Text("Select Outfit")) {
                        List(allOutfits, id: \.self) { outfit in
                            Button(action: {
                                if !title.isEmpty {
                                    saveScheduledOutfit(outfit: outfit)
                                }
                            }) {
                                HStack {
                                    if let imageData = outfit.outfitPic, let image = UIImage(data: imageData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 55, height: 55)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.accentColor, lineWidth: 2)
                                            )
                                    }
                                    
                                    Text(outfit.outfitName ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.never)
                .navigationBarTitle("Schedule Outfit")
                .navigationBarItems(trailing: Button("Cancel", action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            }
        }
            
    var formattedReminderTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: TimeInterval(remindMeBefore)) ?? ""
    }
    

    func saveScheduledOutfit(outfit: OutfitEntity) {
        let context = CoreDataStack.shared.context
        
        let scheduledOutfit = OutfitScheduler(context: context)
        scheduledOutfit.scheduleDate = scheduleDate
        scheduledOutfit.title = title
        scheduledOutfit.schedOfID = outfit.outfitID
        scheduledOutfit.scheduledOutfitPic = outfit.outfitPic
        scheduledOutfit.remindMeBefore = remindMeBefore
        
        if remindMeBefore > 1 {
            let content = UNMutableNotificationContent()
            content.title = "Your Outfit Reminder!"
            content.body = "Don't forget to wear your \(title) outfit!"
            content.sound = .default
            content.badge = 1
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let notificationIdentifier = "outfitReminder_\(dateFormatter.string(from: scheduleDate))"

            
            let reminderTimeInSeconds = remindMeBefore
            let triggerTimeInterval = max(scheduleDate.timeIntervalSinceNow - reminderTimeInSeconds, 1)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTimeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling local notification: \(error.localizedDescription)")
                } else {
                    print("Local notification scheduled successfully")
                }
            }
        }
        CoreDataStack.shared.saveContext()
        closetManager.deleteOutdatedScheduledOutfits()
        closetManager.getAllItems()
        presentationMode.wrappedValue.dismiss()
    }
}
