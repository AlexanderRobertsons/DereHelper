import Foundation
struct LSLog: Codable {
    var noteIndex: Int
    var score: Int
    var sum: Int
    var baseScore: Double
    var baseComboBonus: Int
    var comboBonus: Int
    var basePerfectBonus: Int
    var perfectBonus: Int
    var comboFactor: Double
    var skillBoost: Int
    var lifeRestore: Int
    var currentLife: Int
    var perfectLock: Bool
    var strongPerfectLock: Bool
    var comboContinue: Bool
    var `guard`: Bool
    var toDictionary: [String: Any] {
        return [
            "note_index": noteIndex,
            "score": score,
            "sum": sum,
            "base_score": baseScore,
            "base_combo_bonus": baseComboBonus,
            "combo_bonus": comboBonus,
            "base_perfect_bonus": basePerfectBonus,
            "perfect_bonus": perfectBonus,
            "combo_factor": comboFactor,
            "skill_boost": skillBoost
        ]
    }
}
