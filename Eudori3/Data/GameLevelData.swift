//
//  LevelData.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 29/06/25.
//

import Foundation

let gameLevels: [GameLevelModel] = [
    GameLevelModel(
        level: 1,
        sceneAsset: "Scene1",
        correctDiagnoses: [.overheatingCapacitor],
        reward: 50000,
        unlockedTool: nil,
        expenses: [
            LevelExpense(category: "buyCapacitor", amount: 10000)
        ],
        debtInstallment: 10000,
        refundAmount: 30000,
        canProceedIfRefunded: false,
        nextLevelUnlocked: true,
        loopingMessage: "Kamu harus mengembalikan uang pelanggan. Uangmu tidak cukup untuk membayar cicilan hari ini."
    ),
    
    GameLevelModel(
        level: 2,
        sceneAsset: "Scene2",
        correctDiagnoses: [.degradedCapacitor],
        reward: 70000,
        unlockedTool: .thermalGlasses,
        expenses: [
            LevelExpense(category: "buyTool", amount: 20000),
            LevelExpense(category: "buyCapacitor", amount: 15000)
        ],
        debtInstallment: 10000,
        refundAmount: 25000,
        canProceedIfRefunded: false,
        nextLevelUnlocked: true,
        loopingMessage: "Kesalahan diagnosis menyebabkan refund. Coba lagi untuk hasil yang akurat."
    ),
    
    GameLevelModel(
        level: 3,
        sceneAsset: "Scene3",
        correctDiagnoses: [.reversedPolarity],
        reward: 90000,
        unlockedTool: .multimeter,
        expenses: [
            LevelExpense(category: "buyTool", amount: 30000),
            LevelExpense(category: "buyCapacitor", amount: 20000)
        ],
        debtInstallment: 15000,
        refundAmount: 40000,
        canProceedIfRefunded: false,
        nextLevelUnlocked: false,
        loopingMessage: "Pelanggan kecewa dan meminta uang kembali. Coba lagi dengan diagnosis yang tepat."
    )
]
