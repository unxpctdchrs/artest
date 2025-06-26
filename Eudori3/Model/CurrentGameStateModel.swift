//
//  CurrentGameStateModel.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import Foundation

struct CurrentGameStateModel: Codable {
    let currentLevel: Int
    var completedLevels: Set<Int>
    var levelStars: [Int: Int]
    let mistakesMade: Int
    let debt: Int
    let money: Int
    let shopStatus: [String: Bool]
    let unlockedTools: Set<ToolType>
}
