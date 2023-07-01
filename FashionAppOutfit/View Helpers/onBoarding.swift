//
//  onBoarding.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 13/06/23.
//

import Foundation
import SwiftUI


struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    let numberOfPages = 6
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .blur(radius: 20)
                .saturation(0.0)
                .ignoresSafeArea(.all)

//            if currentPage != numberOfPages - 1 {
//
//                Image("6")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .scaledToFill()
//                    .ignoresSafeArea(.all)
//        }
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(stride(from: 0, to: numberOfPages, by: 1)), id: \.self) { index in
                        Image("\(index + 1)")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                        
                    }
                }
                .tabViewStyle(.page)
            }
            .padding(.top, 25)
            .padding(.bottom, 50)
            if currentPage == numberOfPages - 1 {
                VStack {
                    
                    Button(action: {
                        showOnboarding = false // Dismiss the onboarding view
                    }) {
                        Text("I am ready")
                            .font(.custom("SFPro-Bold", size: 22))
                            .foregroundColor(.black)
                            .frame(width: 170, height: 58, alignment: .center)
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding()
                            
                    }
                }
                Spacer()
            }
        }
    }
}
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}
