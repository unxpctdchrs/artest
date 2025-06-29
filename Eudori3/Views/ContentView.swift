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
    @StateObject var dialogueViewModel: DialogueViewModel
    
    @State var showbuttonstate = true
    
    @State private var currentStep: AppStep = .arExperience
    @State private var showControls = true
    @State private var showChecklist = false
    @State private var showGuide = false
    @State private var showDialogue = false
    
    @State private var currentIndexDialogue: Int = 0
    
    init() {
        let gameManager = GameManager()
        
        _gameManager = StateObject(wrappedValue: gameManager)
        _arViewModel = StateObject(wrappedValue: ARViewModel(gameManager: gameManager))
        _toolsViewModel = StateObject(wrappedValue: ToolsViewModel(gameManager: gameManager))
        _dialogueViewModel = StateObject(wrappedValue: DialogueViewModel())
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
                
                if showDialogue {
                    DialogueView(viewModel: dialogueViewModel, showDialogue: $showDialogue, currentIndexDialogue: $currentIndexDialogue)
                    
                } else {
                    if showControls {
                        ControlView(
                            onChecklistTapped: { showChecklist = true },
                            onGuideTapped: { showGuide = true }
                        )
                        .transition(.opacity)
                    }
                }
                
                if showGuide {
                    GuideView {
                        showGuide = false
                    }
                    .transition(.scale)
                }
                
                if showChecklist {
                    ChecklistView {
                        showChecklist = false
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
                                    
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Button {
                                                arViewModel.gameManager.goToNextLevel()
                                                showDialogue = true
                                            } label: {
                                                Text("GO TO NEXT LEVEL")
                                            }
                                        }
                                    }
                                }
                                if toolsViewModel.isMultimeterActive {
                                    MultimeterToolView(viewModel: toolsViewModel)
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
                .onChange(of: showGuide) { oldValue, newValue in
                    if !oldValue {
                        toolsViewModel.showbuttonstate = false
                    } else {
                        toolsViewModel.showbuttonstate = true
                    }
                }
                .onChange(of: showChecklist) { oldValue, newValue in
                    if !oldValue {
                        toolsViewModel.showbuttonstate = false
                    } else {
                        toolsViewModel.showbuttonstate = true
                    }
                }
                .animation(.easeInOut, value: showGuide)
                .animation(.easeInOut, value: showChecklist)
            }
        }
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
