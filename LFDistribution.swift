import Foundation
struct LFDistribution {
    var samples: [LFSamplePoint<LSScoreBonusGroup>]
    var average: Double {
        if samples.count == 0 {
            return Double(LSScoreBonusGroup.basic.bonusValue)
        } else {
            return samples.reduce(0.0) { $0 + Double($1.value.bonusValue) * $1.probability }
        }
    }
    var maxValue: Int {
        let max = samples.max {
            $0.value.bonusValue < $1.value.bonusValue
        }
        if let max = max {
            return max.value.bonusValue
        } else {
            return LSScoreBonusGroup.basic.bonusValue
        }
    }
    var minValue: Int {
        let min = samples.filter { $0.probability > 0 }.min {
            $0.value.bonusValue < $1.value.bonusValue
        }
        if let min = min {
            return min.value.bonusValue
        } else {
            return LSScoreBonusGroup.basic.bonusValue
        }
    }
}
