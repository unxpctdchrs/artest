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
    @State private var showReceipt = false
    
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
                    ChecklistView(
                        onDismiss: {
                            showChecklist = false
                        },
                        onShowReceipt: {
                            showChecklist = false
                            showReceipt = true
                        }
                    )
                    .transition(.scale)
                }
                
                if showGuide {
                    GuideView {
                        showGuide = false
                    }
                    .transition(.scale)
                }
                
                if showReceipt {
                    ReceiptView {
                        showReceipt = false
                    }
                    .transition(.scale)
                }
                
//                if (showbuttonstate) {
//                    Button {
//                        arViewModel.isPlacingObject = true
//                        arViewModel.gameManager.currentLevel = 1
//                        showbuttonstate = false
//                    } label: {
//                        Text("Hello, World!")
//                    }
//                }
                
                PlaceEntityButtonView(arViewModel: arViewModel, toolsViewModel: toolsViewModel)
                
                if self.toolsViewModel.isThermalGlassActive {
                    ThermalVision().ignoresSafeArea(.all)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        if toolsViewModel.isThermalGlassActive {
                            ToolsView(toolsViewModel: toolsViewModel)
                        }
                        Spacer()
//                        Button {
//                            arViewModel.gameManager.goToNextLevel()
//                        } label: {
//                            Text("GO TO NEXT LEVEL")
//                        }
                    }
                }
            }
            if toolsViewModel.isMultimeterActive {
                MultimeterToolView(viewModel: toolsViewModel)
            }
        }
        .onChange(of: showGuide) { oldValue, newValue in
            if !oldValue {
                toolsViewModel.isMultimeterActive = false
                toolsViewModel.isThermalGlassActive = false
                toolsViewModel.showbuttonstate = false
            } else {
                if !arViewModel.objectIsPlaced {
                    toolsViewModel.showbuttonstate = true
                }
            }
        }
        .onChange(of: showChecklist) { oldValue, newValue in
            if !oldValue {
                toolsViewModel.isMultimeterActive = false
                toolsViewModel.isThermalGlassActive = false
                toolsViewModel.showbuttonstate = false
            } else {
                if !arViewModel.objectIsPlaced {
                    toolsViewModel.showbuttonstate = true
                }
            }
        }
        
        .onChange(of: showReceipt) { oldValue, newValue in
            if !oldValue {
                toolsViewModel.isMultimeterActive = false
                toolsViewModel.isThermalGlassActive = false
                toolsViewModel.showbuttonstate = false
            } else {
                if !arViewModel.objectIsPlaced {
                    toolsViewModel.showbuttonstate = true
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
