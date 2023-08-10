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
    @State private var selectedOutfitEntity: OutfitEntity? = nil

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedOutfits, id: \.0) { date, scheduledOutfits in
                    Section(header: Text(dateFormatter.string(from: date))) {
                        ForEach(scheduledOutfits, id: \.self) { outfit in
                            ScheduleItemView(outfitScheduler: outfit, closetManager: closetManager, selectedOutfitEntity: $selectedOutfitEntity)
                                .swipeActions {
                                    Button(action: {
                                        closetManager.deleteScheduledOutfit(outfit: outfit)
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                            
                        }

                    }
                }
            }
            .navigationTitle("Schedule")
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
            .onAppear {
                closetManager.deleteOutdatedScheduledOutfits()
            }
        }
        .sheet(item: $selectedOutfitEntity) { outfitEntity in
            NavigationView {
                SavedOutfitView(outfit: outfitEntity)
            }
        }
    }
    
    private var groupedOutfits: [(Date, [OutfitScheduler])] {
        Dictionary(grouping: outfits, by: { Calendar.current.startOfDay(for: $0.scheduleDate!) })
            .sorted(by: { $0.key < $1.key })
    }
}


struct ScheduleItemView: View {
    let outfitScheduler: OutfitScheduler
    @ObservedObject var closetManager: ClosetManager
    @Binding var selectedOutfitEntity: OutfitEntity?

    var body: some View {
        Button(action: {
            if let outfitID = outfitScheduler.schedOfID,
               let outfitEntity = closetManager.getOutfitEntity(withID: outfitID) {
                selectedOutfitEntity = outfitEntity
            }
        }) {
            HStack(spacing: 8) {
                if let imageData = outfitScheduler.scheduledOutfitPic, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 55, height: 55)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Text(outfitScheduler.title ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(formatScheduleDate(outfitScheduler.scheduleDate))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.secondary)
            }
        }
    }

    func formatScheduleDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
