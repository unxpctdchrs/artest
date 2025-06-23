//
//  ARViewModel.swift
//  Eudori3
//
//  Created by Vigo on 21/06/25.
//

import Foundation
import RealityKit

class ARViewModel: ObservableObject {
    @Published var isPlacingObject: Bool = false
    @Published var currentLevel: Int = 0 {
        didSet {
            loadLevel(index: currentLevel)
        }
    }
    @Published var focusEntityState: Bool = true
    
    var activeLevel: Level?
    weak var arView: ARView?
    
    // Add level here
    private let levels: [Int: Level] = [
        1: Level1(),
        2: Level2(),
    ]
    
    // load and activate a new level
    func loadLevel(index: Int) {
        // Clean up current level if any
        if let currentLevel = activeLevel, let arView = self.arView {
            currentLevel.cleanupLevel(in: arView, arViewModel: self)
        }
        
        // Load the new level
        if let newLevel = levels[index] {
            self.activeLevel = newLevel
        } else {
            print("ERROR: Level with index \(index) not found.")
            activeLevel = nil // Clear active level if not found
        }
    }
    
    // placing the level
    func placeCurrentLevel(transform: Transform) {
        guard let arView = self.arView else {
            print("ARView not available for placement.")
            return
        }
        
        guard let level = activeLevel else {
            print("No active level to place.")
            return
        }
        
        _ = level.setupLevel(in: arView, with: transform, arViewModel: self)
        DispatchQueue.main.async {
            self.focusEntityState = false
        }
    }
    
    func performUpdate(deltaTime: Double) {
        activeLevel?.update(deltaTime: deltaTime, arViewModel: self)
    }
    
    func goToNextLevel() {
        let nextIndex = currentLevel + 1
        if levels[nextIndex] != nil {
            currentLevel = nextIndex
        } else {
            print("No more levels or reached max level. Looping back to Level 1.")
            currentLevel = 1
        }
    }
}
