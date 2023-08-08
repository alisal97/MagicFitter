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
    
    @FetchRequest(entity: OutfitEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \OutfitEntity.date, ascending: false)])
    var allOutfits: FetchedResults<OutfitEntity>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scheduling Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Select Outfit")) {
                    List(allOutfits, id: \.self) { outfit in
                        Button(action: {
                            saveScheduledOutfit(outfit: outfit)
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
                            .simultaneousGesture(TapGesture()
                                .onEnded({ _ in
                                    saveScheduledOutfit(outfit: outfit)
                                }))
                            
                        }
                    }
                }
            }
            .navigationBarTitle("Schedule Outfit")
            .navigationBarItems(trailing: Button("Cancel", action: {
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
        scheduledOutfit.scheduledOutfitPic = outfit.outfitPic
        
        CoreDataStack.shared.saveContext()
        closetManager.deleteOutdatedScheduledOutfits()
        closetManager.getAllItems()
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
