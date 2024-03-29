import UIKit
import SwiftyJSON
fileprivate extension Int {
    func addGreatPercent(_ percent: Double) -> Int {
        return Int(round(Double(self) * (1 - 0.3 * percent / 100)))
    }
}
extension LSNote {
    func expectation(in distribution: LFDistribution) -> Double {
        let expectation = distribution.samples.reduce(0.0) { $0 + round(baseScore * comboFactor * Double($1.value.bonusValue) / 10000) * $1.probability }
        return expectation
    }
}
class LiveFormulator {
    var notes: [LSNote]
    var bonuses: [LSSkill]
    lazy var distributions: [LFDistribution] = {
        return self.generateScoreDistributions()
    }()
    init(notes: [LSNote], bonuses: [LSSkill]) {
        self.bonuses = bonuses
        self.notes = notes
    }
    var averageScore: Int {
        var sum = 0.0
        for i in 0..<notes.count {
            let note = notes[i]
            let distribution = distributions[i]
            sum += note.expectation(in: distribution)
        }
        return Int(round(sum)).addGreatPercent(LiveSimulationAdvanceOptionsManager.default.greatPercent)
    }
    var maxScore: Int {
        var sum = 0
        for i in 0..<notes.count {
            let note = notes[i]
            let distribution = distributions[i]
            sum += Int(round(note.baseScore * note.comboFactor * Double(distribution.maxValue) / 10000))
        }
        return sum.addGreatPercent(LiveSimulationAdvanceOptionsManager.default.greatPercent)
    }
    var minScore: Int {
        var sum = 0
        for i in 0..<notes.count {
            let note = notes[i]
            let distribution = distributions[i]
            sum += Int(round(note.baseScore * note.comboFactor * Double(distribution.minValue) / 10000))
        }
        return sum.addGreatPercent(LiveSimulationAdvanceOptionsManager.default.greatPercent)
    }
    private func generateScoreDistributions() -> [LFDistribution] {
        var distributions = [LFDistribution]()
        for i in 0..<notes.count {
            let note = notes[i]
            let validBonuses = bonuses.filter { $0.range.contains(note.sec) }
            var samples = [LFSamplePoint<LSScoreBonusGroup>]()
            for mask in 0..<(1 << validBonuses.count) {
                var bonusGroup = LSScoreBonusGroup.basic
                var p = 1.0
                for j in 0..<validBonuses.count {
                    let bonus = validBonuses[j]
                    if mask & (1 << j) != 0 {
                        p *= bonus.probability
                        switch bonus.type {
                        case .comboBonus, .allRound:
                            bonusGroup.baseComboBonus = max(bonusGroup.baseComboBonus, bonus.value)
                        case .perfectBonus, .overload, .concentration:
                            bonusGroup.basePerfectBonus = max(bonusGroup.basePerfectBonus, bonus.value)
                        case .skillBoost:
                            bonusGroup.skillBoost = max(bonusGroup.skillBoost, bonus.value)
                        case .deep, .synergy:
                            bonusGroup.basePerfectBonus = max(bonusGroup.basePerfectBonus, bonus.value)
                            bonusGroup.baseComboBonus = max(bonusGroup.baseComboBonus, bonus.value2)
                        default:
                            break
                        }
                    } else {
                        p *= 1 - bonus.probability
                    }
                }
                let sample = LFSamplePoint<LSScoreBonusGroup>.init(probability: p, value: bonusGroup)
                samples.append(sample)
            }
            let distribution = LFDistribution(samples: samples)
            distributions.append(distribution)
        }
        return distributions
    }
}
