//
//  ARViewModel.swift
//  Eudori3
//
//  Created by Vigo on 21/06/25.
//

import Foundation
import RealityKit
import Combine

class ARViewModel: ObservableObject {
    @Published var isPlacingObject: Bool = false
    @Published var focusEntityState: Bool = true
    
    weak var arView: ARView? {
        didSet {
            if let arView = self.arView {
                print("ARViewModel: ARView assigned. Setting up level cleanup observation.")
                setupLevelCleanupObservation(for: arView)
            } else {
                levelCleanupCancellable?.cancel()
                levelCleanupCancellable = nil
            }
        }
    }
    
    @Published var gameManager: GameManager
    
    private var levelCleanupCancellable: AnyCancellable?
    
    var focusState: Bool = false
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    private func setupLevelCleanupObservation(for arView: ARView) {
        // Cancel any existing subscription first to prevent duplicates if arView is reassigned
        levelCleanupCancellable?.cancel()
        
        levelCleanupCancellable = gameManager.$activeLevel
            .sink { [weak self, weak arView] (newActiveLevel: Level?) in
                guard let self = self, let arView = arView else { return }
                
                // Perform cleanup of the *previous* level when a new one is loaded
                // This sink will now only trigger after arView has been set.
                // For simplicity, clearing all anchors. In a real app, track and remove specific entities.
                if arView.scene.anchors.count > 0 {
                    print("ARViewModel: Cleaning up previous level's entities in ARView.")
                    arView.scene.anchors.removeAll()
                }
            }
    }
    
    // placing the level
    func placeCurrentLevel(transform: Transform, toolsViewModel: ToolsViewModel) {
        guard let arView = self.arView else {
            print("ARView not available for placement.")
            return
        }
        
        guard let level = gameManager.activeLevel else {
            print("No active level to place.")
            return
        }
        
        _ = level.setupLevel(in: arView, with: transform, arViewModel: self, toolsViewModel: toolsViewModel)
        DispatchQueue.main.async {
            self.focusEntityState = false
        }
    }
}
