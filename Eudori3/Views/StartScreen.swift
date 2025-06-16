//
//  StartScreen.swift
//  Eudori3
//
//  Created by Vigo on 14/06/25.
//

import SwiftUI

struct StartScreen: View {
    @State private var isStart: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    isStart = true
                } label: {
                    Text("Mulai")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(PlainButtonStyle())
            .navigationDestination(isPresented: $isStart) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    StartScreen()
}
