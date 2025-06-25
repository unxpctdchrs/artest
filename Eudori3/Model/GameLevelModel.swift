//
//  GameLevelModel.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import Foundation

struct GameLevelModel: Codable {
    let level: Int
    let sceneAsset: String
    let correctDiagnoses: [DiagnosisType]?
    let reward: Int
    let unlockedTool: String?
    let expenses: [LevelExpense]
    
    var totalExpenses: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

struct LevelExpense: Codable {
    let category: String
    let amount: Int
}

enum DiagnosisType: String, Codable {
    case overheatingCapacitor
    case reversedPolarity
    case degradedCapacitor
}

enum ToolType: String, Codable {
    case multimeter
    case thermalGoggles
}
