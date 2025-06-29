//
//  ToolsView.swift
//  Eudori3
//
//  Created by Vigo on 14/06/25.
//

import SwiftUI

struct ToolsView: View {
    @ObservedObject var toolsViewModel: ToolsViewModel
    
    var body: some View {
        HStack {
//            Button {
//                toolsViewModel.isMagnifyingGlassActive.toggle()
//            } label: {
//                Image(systemName: "magnifyingglass")
//                    .foregroundStyle(toolsViewModel.isMagnifyingGlassActive ? .green : .gray)
//            }
//            
//            Spacer()
            
//            Button {
//                toolsViewModel.isMultimeterActive.toggle()
//            } label: {
//                Image(systemName: "appletvremote.gen2")
//                    .foregroundStyle(toolsViewModel.isMultimeterActive ? .green : .gray)
//            }
//            
//            Spacer()
            
            Button {
                toolsViewModel.isThermalGlassActive.toggle()
            } label: {
                Image(systemName: "sunglasses")
                    .foregroundStyle(toolsViewModel.isThermalGlassActive ? .green : .gray)
            }
            
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 150, height: 38)
        .padding()
        .font(.title)
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ToolsView(toolsViewModel: ToolsViewModel(gameManager: GameManager()))
}
