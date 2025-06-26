//
//  ContentView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct ContentView : View {
//<<<<<<< HEAD
//    @StateObject var arViewModel = ARViewModel()
//    @StateObject var toolsViewModel = ToolsViewModel()
//    @StateObject var multimeterViewModel = MultimeterViewModel()
//
//    var body: some View {
//        ZStack(alignment: .center){
//=======
    @StateObject var gameManager: GameManager
    
    @StateObject var arViewModel: ARViewModel
    @StateObject var toolsViewModel: ToolsViewModel
    
    @State var showbuttonstate = true
    
    init() {
        let gameManager = GameManager()
        
        _gameManager = StateObject(wrappedValue: gameManager)
        _arViewModel = StateObject(wrappedValue: ARViewModel(gameManager: gameManager))
        _toolsViewModel = StateObject(wrappedValue: ToolsViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        ZStack(alignment: .center) {
//>>>>>>> dev
            ARViewContainer(arViewModel: arViewModel, toolsViewModel: toolsViewModel).edgesIgnoringSafeArea(.all)
            
            if (toolsViewModel.isThermalGlassActive) {
                ThermalVision().edgesIgnoringSafeArea(.all)
            }
            
            if (showbuttonstate) {
                Button {
                    arViewModel.isPlacingObject = true
                    arViewModel.gameManager.currentLevel = 1
                    showbuttonstate = false
                } label: {
                    Text("Hello, World!")
                }
            }
            
            VStack {
                Spacer()
                HStack {
//<<<<<<< HEAD
//                    ToolsView(toolsViewModel: toolsViewModel)
//=======
                    VStack {
                        ToolsView(toolsViewModel: toolsViewModel)
                    }
//>>>>>>> dev
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
