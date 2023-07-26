//
//  GenerateView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 25/07/23.
//

import SwiftUI
import UIKit
import CoreData

struct GenerateView: View {
    let item: ClosetItemEntity
    @ObservedObject var closetManager: ClosetManager
    @State private var includeJacket = true
    @State var generatedOutfitItems: [ClosetItemEntity] = []
    @State private var showFeedback = false
    @State var showGeneratedOutfit = false

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    GenerateView(item: ClosetItemEntity() , closetManager: ClosetManager())
}
