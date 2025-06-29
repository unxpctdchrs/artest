//
//  ContentView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var gameManager: GameManager
    @StateObject var arViewModel: ARViewModel
    @StateObject var toolsViewModel: ToolsViewModel
    @StateObject var dialogueViewModel = DialogueViewModel()
    
    @State private var currentStep: AppStep = .onboarding
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
                    currentStep = .dialogue(0)
                }
                
            case .dialogue(let id):
                ZStack {
                    CameraPermissionView {
                        ARViewContainer(arViewModel: arViewModel, toolsViewModel: toolsViewModel)
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    if controlConfig.show {
                        ControlView(
                            onChecklistTapped: { showChecklist = true },
                            onGuideTapped: { showGuide = true },
                            showReputationBar: controlConfig.showReputationBar,
                            showDebtBar: controlConfig.showDebtBar,
                            showGuideButton: controlConfig.showGuideButton,
                            showChecklistButton: controlConfig.showChecklistButton
                        )
                    }
                    
                    DialogueView(viewModel: dialogueViewModel)
                        .onAppear {
                            let _: Int
                            func nextStep(after id: Int) -> AppStep {
                                switch id {
                                case 0: return .dialogue(1)
                                case 1: return .gameplay
                                case 2: return .dialogue(3)
                                case 3: return .dialogue(4)
                                case 4: return .dialogue(5)
                                case 5: return .dialogue(6)
                                case 6: return .dialogue(7)
                                default: return .gameplay
                                }
                            }
                            
                            dialogueViewModel.configure(startIndex: id, endIndex: id + 1) {
                                print("Dialogue finished, moving to next step")
                                currentStep = nextStep(after: id)
                            }
                        }
                }
                
            case .gameplay:
                CameraPermissionView {
                    ARViewContainer(arViewModel: arViewModel, toolsViewModel: toolsViewModel)
                        .edgesIgnoringSafeArea(.all)
                }
                
                if controlConfig.show {
                    ControlView(
                        onChecklistTapped: { showChecklist = true },
                        onGuideTapped: { showGuide = true },
                        showReputationBar: controlConfig.showReputationBar,
                        showDebtBar: controlConfig.showDebtBar,
                        showGuideButton: controlConfig.showGuideButton,
                        showChecklistButton: controlConfig.showChecklistButton
                    )
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
            }
        }
        .animation(.easeInOut, value: currentStep)
    }
    
    // MARK: - Dynamic UI Config
    private var controlConfig: ControlUIConfig {
        switch currentStep {
        case .gameplay:
            return ControlUIConfig(
                show: true,
                showReputationBar: true,
                showDebtBar: true,
                showGuideButton: true,
                showChecklistButton: true
            )
            
        case .dialogue(let id):
            switch id {
            case 0:
                return ControlUIConfig(show: false)
            case 1:
                return ControlUIConfig(
                    show: true,
                    showReputationBar: false,
                    showDebtBar: true,
                    showGuideButton: false,
                    showChecklistButton: false
                )
            case 2:
                return ControlUIConfig(
                    show: true,
                    showReputationBar: false,
                    showDebtBar: true,
                    showGuideButton: false,
                    showChecklistButton: true
                )
            case 4:
                return ControlUIConfig(
                    show: true,
                    showReputationBar: false,
                    showDebtBar: true,
                    showGuideButton: true,
                    showChecklistButton: true
                )
            case 5:
                return ControlUIConfig(
                    show: true,
                    showReputationBar: true,
                    showDebtBar: false,
                    showGuideButton: false,
                    showChecklistButton: false
                )
            case 3, 6, 7:
                return ControlUIConfig(
                    show: true,
                    showReputationBar: true,
                    showDebtBar: true,
                    showGuideButton: true,
                    showChecklistButton: true
                )
            default:
                return ControlUIConfig()
            }
            
        default:
            return ControlUIConfig()
        }
    }
}

// MARK: - Supporting Types

enum AppStep: Equatable {
    case onboarding
    case prologue
    case dialogue(Int)
    case gameplay
}

struct ControlUIConfig {
    var show: Bool = false
    var showReputationBar: Bool = true
    var showDebtBar: Bool = true
    var showGuideButton: Bool = true
    var showChecklistButton: Bool = true
}

#Preview {
    ContentView()
}
