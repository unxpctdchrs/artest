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
    let reward: Int                  // Pendapatan dari servis jika sukses
    let unlockedTool: ToolType?     // Kacamata termal / Multimeter jika ada
    let expenses: [LevelExpense]    // Semua pengeluaran
    let debtInstallment: Int?       // Cicilan hutang di level ini
    let refundAmount: Int?          // Jika salah diagnosis
    let canProceedIfRefunded: Bool  // false = looping level
    let nextLevelUnlocked: Bool     // false jika level gagal
    let loopingMessage: String?     // alasan gagal

    var totalExpenses: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var netIncome: Int {
        reward - totalExpenses - (debtInstallment ?? 0) - (refundAmount ?? 0)
    }
}

struct LevelExpense: Codable {
    let category: String
    let amount: Int
}

enum ExpenseCategory: String, Codable {
    case buyTool        // beli alat baru
    case buyCapacitor   // beli komponen
    case repairCost     // biaya perbaikan
}

enum DiagnosisType: String, Codable {
    case overheatingCapacitor
    case reversedPolarity
    case degradedCapacitor
}

enum ToolType: String, Codable {
    case multimeter
    case thermalGlasses
}
