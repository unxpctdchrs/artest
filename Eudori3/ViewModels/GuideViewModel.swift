//
//  GuideViewModel.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 29/06/25.
//

import Foundation

class GuideViewModel: ObservableObject {
    @Published var unlockedTools: Set<ToolType> = []
    
    var guideImageName: String {
        if unlockedTools.contains(.multimeter) && unlockedTools.contains(.thermalGlasses) {
            return "CompleteGuide"
        } else if unlockedTools.contains(.thermalGlasses) {
            return "PolaritasTerbalikGuide"
        } else {
            return "TeganganTerlaluTinggiGuide"
        }
    }
    
    init(from gameState: CurrentGameStateModel) {
        self.unlockedTools = gameState.unlockedTools
    }
}
