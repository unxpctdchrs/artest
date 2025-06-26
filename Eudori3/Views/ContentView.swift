//
//  ContentView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct ContentView : View {
    @StateObject var arViewModel = ARViewModel()
    @StateObject var toolsViewModel = ToolsViewModel()
//    @StateObject var multimeterViewModel = MultimeterViewModel()

    var body: some View {
        ZStack(alignment: .center){
            ARViewContainer(arViewModel: arViewModel, toolsViewModel: toolsViewModel).edgesIgnoringSafeArea(.all)
            
            Button {
                arViewModel.isPlacingObject = true
                arViewModel.gameManager.currentLevel = 1
            } label: {
                Text("Hello, World!")
            }
            
            VStack {
                Spacer()
                HStack {
                    ToolsView(toolsViewModel: toolsViewModel)
                    Spacer()
                    Button {
                        arViewModel.gameManager.goToNextLevel()
                    } label: {
                        Text("GO TO NEXT LEVEL")
                    }
                }
            }
            if toolsViewModel.isMultimeterActive {
                MultimeterToolView(viewModel: toolsViewModel)
            }
//            if toolsViewModel.activeToolID == "multimeter" {
//                MultimeterToolView()
//            } else {
//                Text("Tool: \(toolsViewModel.activeToolID ?? "nil")")
//            }
        }
    }
}

#Preview {
    ContentView()
}
