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

    var body: some View {
        NavigationStack {
            
            
        }
        .sheet(isPresented: $showModal) {
            ScheduleViewController(closetManager: closetManager)
        }
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
    }

}

