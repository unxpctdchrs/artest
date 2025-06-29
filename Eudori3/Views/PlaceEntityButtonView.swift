//
//  PlaceEntityButtonView.swift
//  Eudori3
//
//  Created by Vigo on 29/06/25.
//

import SwiftUI

struct PlaceEntityButtonView: View {
    @ObservedObject var arViewModel: ARViewModel
    @ObservedObject var toolsViewModel: ToolsViewModel
    
    @State private var showbuttonstate: Bool = true
    @State private var isFocused: Bool = true
    
    var body: some View {
        ZStack {
//            HStack {
//                Text("test")
//            }
//            .frame(maxWidth: 560, maxHeight: 260)
//            .background(.orange)
            
            if showbuttonstate {
                Button {
                    arViewModel.isPlacingObject = true
                    arViewModel.gameManager.currentLevel = 1
                    showbuttonstate = false
                } label: {
                    if arViewModel.focusState {
                        Image(systemName: "plus.circle").font(.system(size: 160))
                            .foregroundStyle(Color("theColorBlue"))
                            .opacity(0.4)
                    } else if !arViewModel.focusState {
                        Image(systemName: "plus.circle.dashed").font(.system(size: 160))
                            .foregroundStyle(.white)
                            .opacity(0.4)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    let gameManager = GameManager()
    
    PlaceEntityButtonView(arViewModel: ARViewModel(gameManager: gameManager), toolsViewModel: ToolsViewModel(gameManager: gameManager))
}
