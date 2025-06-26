//
//  ContentView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct ContentView : View {
    @StateObject var gameManager: GameManager
    
    @StateObject var arViewModel: ARViewModel
    @StateObject var toolsViewModel: ToolsViewModel
    
    @State var showbuttonstate = true
    
    @State private var currentStep: AppStep = .onboarding
    @State private var showControls = true
    @State private var showChecklist = false
    @State private var showGuide = false
    
    init() {
        let gameManager = GameManager()
        
        _gameManager = StateObject(wrappedValue: gameManager)
        _arViewModel = StateObject(wrappedValue: ARViewModel(gameManager: gameManager))
        _toolsViewModel = StateObject(wrappedValue: ToolsViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .onboarding:
                OnboardingView {
                    currentStep = .prologue
                }
            case .prologue:
                PrologueView {
                    currentStep = .arExperience
                }
            case .arExperience:
                CameraPermissionView {
                    ARViewContainer(arViewModel: arViewModel, toolsViewModel: toolsViewModel)
                        .edgesIgnoringSafeArea(.all)
                }
                
                if showControls {
                    ControlView(
                        onChecklistTapped: { showChecklist = true },
                        onGuideTapped: { showGuide = true }
                    )
                    .transition(.opacity)
                }
                
                if showChecklist {
                    ChecklistView {
                        showChecklist = false
                    }
                    .transition(.scale)
                }
                
                if showGuide {
                    GuideView {
                        showGuide = false
                    }
                    .transition(.scale)
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
                        Spacer()
                        Button {
                            arViewModel.gameManager.goToNextLevel()
                        } label: {
                            Text("GO TO NEXT LEVEL")
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: showGuide)
        .animation(.easeInOut, value: showChecklist)
    }
}

enum AppStep {
    case onboarding
    case prologue
    case arExperience
}

#Preview {
    ContentView()
}
