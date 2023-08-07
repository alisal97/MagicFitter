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
    
    var body: some View {
        NavigationView {
                Section(header: Text("Scheduling Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                }
            Form {
                Section(header: Text("Select Outfit")) {
                    List(closetManager.savedOutfits, id: \.self) { outfit in
                        Button(action: {
                            saveScheduledOutfit(outfit: outfit)
                        }) {
                            Text(outfit.outfitName ?? "")
                        }
                    }
                }
            }
            .navigationBarTitle("Schedule Outfit")
            .navigationBarItems(trailing: Button("Done", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
    
    func saveScheduledOutfit(outfit: OutfitEntity) {
        let context = CoreDataStack.shared.context
        
        let scheduledOutfit = OutfitScheduler(context: context)
        scheduledOutfit.scheduleDate = scheduleDate
        scheduledOutfit.title = title
        scheduledOutfit.schedOfID = outfit.outfitID
        CoreDataStack.shared.saveContext()
        presentationMode.wrappedValue.dismiss()
    }
}
//// Step 5: Button to Trigger Scheduling
//struct ContentView: View {
//    @State private var isPresentingScheduleView = false
//    @ObservedObject var closetManager: ClosetManager // Pass your closet manager here
//
//    var body: some View {
//        VStack {
//            Button("Schedule Outfit") {
//                isPresentingScheduleView = true
//            }
//            .sheet(isPresented: $isPresentingScheduleView) {
//                ScheduleOutfitView(closetManager: closetManager)
//            }
//        }
//    }
//}

#Preview {
    ScheduleViewController( closetManager: ClosetManager())
}
