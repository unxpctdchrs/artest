//
//  ControlView.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import SwiftUI

struct ControlView: View {
    var onChecklistTapped: () -> Void
    var onGuideTapped: () -> Void
    var progress: CGFloat = 0
    
    var showReputationBar: Bool
    var showDebtBar: Bool
    var showGuideButton: Bool
    var showChecklistButton: Bool
    
    var body: some View {
        VStack(alignment: .trailing) {
            // Top Bar
            if showReputationBar || showDebtBar {
                HStack {
                    if showReputationBar {
                        // Reputation Bar
                        HStack(spacing: 12) {
                            Text("Reputasi Toko")
                                .foregroundColor(.white)
                                .font(.custom("Nunito-SemiBold", size: 20))
                                .padding(.trailing, 12)
                            
                            ForEach(0..<3) { _ in
                                ZStack {
                                    Circle()
                                        .fill(Color("ThumbsBg"))
                                        .frame(width: 35, height: 35)
                                    
                                    Image(systemName: "hand.thumbsup.fill")
                                        .foregroundColor(Color("Thumbs"))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color("Main"))
                        .cornerRadius(6)
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    
                    if showDebtBar {
                        Image(systemName: "dollarsign.bank.building")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color("Main"))
                        
                        ZStack(alignment: .leading) {
                            Image("ProgressBar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 50)
                            
                            Image("ReputationBar")
                                .resizable()
                                .frame(width: 280 * progress, height: 40)
                                .padding(.leading, 30)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                if showGuideButton {
                    ControlButton(iconName: "BookIcon", label: "Panduan") {
                        onGuideTapped()
                    }
                }
                
                if showChecklistButton {
                    ControlButton(iconName: "ChecklistIcon", label: "Checklist") {
                        onChecklistTapped()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

struct ControlButton: View {
    let iconName: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(iconName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100)
                
                Text(label)
                    .font(.custom("Nunito-Bold", size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
            .frame(width: 100, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("TapableArea"))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ControlView(
        onChecklistTapped: {},
        onGuideTapped: {},
        showReputationBar: true,
        showDebtBar: true,
        showGuideButton: false,
        showChecklistButton: true
    )
}
