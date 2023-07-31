//
//  onBoardingView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 31/07/23.
//

import Foundation
import SwiftUI

struct onBoardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        
        Button(action: {
            showOnboarding = false
        }) {
            Text("I am ready")
                .font(.custom("SFPro-Bold", size: 21))
                .foregroundColor(.black)
                .frame(width: 169, height: 57, alignment: .center)
                .background(Color.white)
                .cornerRadius(15)
                .padding()
        }
    }
}

#Preview {
    onBoardingView(showOnboarding: .constant(true))
}
