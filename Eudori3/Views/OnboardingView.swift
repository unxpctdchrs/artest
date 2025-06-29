//
//  OnboardingView.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    
    var body: some View {
        
            ZStack {
                Image("Onboarding")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                
                VStack {
//                    Text("LLOYD:\nELECTROFIX JOURNEY")
//                        .font(.custom("Slackey-Regular", size: 70))
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.white)
                    
                    Image("titlescreen")
                    
                    Spacer().frame(maxHeight: 50)
                    
                    Button {
                        onFinish()
                    } label: {
                        Text("Mulai")
                            .font(.custom("Nunito-Bold", size: 38))
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                            .background(Color("TapableArea"))
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    }
                    
                }
            }
            .ignoresSafeArea()
        }
    
}

#Preview {
    OnboardingView{}
}
