//
//  ScheduleView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 07/08/23.
//

import SwiftUI

struct ScheduleView: View {
    @State private var showModal = false
    @ObservedObject var closetManager: ClosetManager
    @FetchRequest(entity: OutfitScheduler.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \OutfitScheduler.scheduleDate, ascending: true)])
    var outfits: FetchedResults<OutfitScheduler>
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedOutfits, id: \.0) { date, scheduledOutfits in
                    Section(header: Text(dateFormatter.string(from: date))) {
                        ForEach(scheduledOutfits, id: \.self) { outfit in
                            HStack {
                                if let imageData = outfit.scheduledOutfitPic, let image = UIImage(data: imageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 55, height: 55)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Text(outfit.title ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Button(action: {
                                    closetManager.deleteScheduledOutfit(outfit: outfit)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            
                        }
                    }
                    .onAppear {
                        closetManager.deleteOutdatedScheduledOutfits()
                    }
                }
            } 
            .navigationTitle("Scheduled Outfits")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                Button(action: {
                    showModal = true
                }) {
                    Image(systemName: "calendar.badge.plus")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                        .background(Color.gray)
                        .cornerRadius(20)
                }
            )
            .sheet(isPresented: $showModal) {
                ScheduleViewController(closetManager: closetManager)
            }
        }
    }
    
    private var groupedOutfits: [(Date, [OutfitScheduler])] {
        Dictionary(grouping: outfits, by: { Calendar.current.startOfDay(for: $0.scheduleDate!) })
            .sorted(by: { $0.key < $1.key })
    }
}


