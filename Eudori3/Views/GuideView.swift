//
//  GuideView.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import SwiftUI

struct GuideView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Tapped background")
                        onDismiss()
                    }
                    .zIndex(0)
                
                Image("CompleteGuide")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.9)
                    .zIndex(1)
            }
            .overlay(alignment: .topLeading) {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .background(Circle().fill(Color("TapableArea")))
                }
                .padding()
                .padding(.leading, 24)
                .zIndex(3)
            }
        }
    }
}

#Preview {
    GuideView{}
}
