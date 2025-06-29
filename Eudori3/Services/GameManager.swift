//
//  GameManager.swift
//  Eudori3
//
//  Created by Vigo on 24/06/25.
//

import Foundation
import RealityKit
import Combine
import SwiftUICore

class GameManager: ObservableObject {
    @Published var currentLevel: Int = 0 {
        didSet {
            loadLevel(index: currentLevel)
        }
    }
    
    @Published var activeLevel: Level?
    
    // Add level here
    private let levels: [Int: Level] = [
//        1: Level1(),
        1: LevelTutorial(),
//        2: Level1(),
    ]
    
    // load and activate a new level
    func loadLevel(index: Int) {
        if let newLevel = levels[index] {
            self.activeLevel = newLevel
        } else {
            print("ERROR: Level with index \(index) not found.")
            activeLevel = nil // Clear active level if not found
        }
    }
    
    func performUpdate(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        activeLevel?.update(deltaTime: deltaTime, arViewModel: arViewModel, toolsViewModel: toolsViewModel)
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
