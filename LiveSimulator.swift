import UIKit
import SwiftyJSON
typealias LSResultClosure = (LSResult, [LSLog]) -> Void
class LiveSimulator {
    var notes: [LSNote]
    var bonuses: [LSSkill]
    var totalLife: Int
    var difficulty: CGSSLiveDifficulty
    init(notes: [LSNote], bonuses: [LSSkill], totalLife: Int, difficulty: CGSSLiveDifficulty) {
        self.notes = notes
        self.bonuses = bonuses
        self.totalLife = totalLife
        self.difficulty = difficulty
    }
    var simulateResult = [Int]()
    var remainedLives = [Int]()
    func simulateOptimistic1(options: LSOptions = [], callback: LSResultClosure? = nil) {
        var actions = [LSAction]()
        for (index, bonus) in bonuses.enumerated() {
            actions += [LSAction.skillStart(String(index), bonus), .skillEnd(String(index), bonus)]
        }
        actions.sort { ($0.timeOffset, $0.order) < ($1.timeOffset, $1.order) }
        let initialLife = options.contains(.doubleHP) ? 2 * totalLife : totalLife
        var game = LSGame(initialLife: initialLife, maxLife: 2 * totalLife, numberOfNotes: notes.count, difficulty: difficulty)
        game.shouldGenerateLogs = options.contains(.detailLog)
        game.afkMode = options.contains(.afk)
        var actionSlice = ArraySlice(actions)
        for note in notes {
            let radius = perfectRadius[difficulty]![note.rangeType]!
            let concentratedRadius = concentratedPerfectRadius[difficulty]![note.rangeType]!
            while let action = actionSlice.first, action.timeOffset < note.sec - (game.hasConcentration ? concentratedRadius : radius) {
                actionSlice.removeFirst()
                game.perform(action)
            }
            var tempGame = game
            var tempActionSlice = actionSlice
            tempGame.perform(.note(note))
            var snapshotActionSlice = actionSlice
            var snapshot = game
            while let action = snapshotActionSlice.first, action.timeOffset < note.sec + radius {
                snapshotActionSlice.removeFirst()
                snapshot.perform(action)
                if snapshot.hasConcentration && action.timeOffset > note.sec + concentratedRadius {
                    continue
                }
                var oneTry = snapshot
                oneTry.perform(.note(note))
                if oneTry.score > tempGame.score ||
                    (oneTry.currentLife > tempGame.currentLife && oneTry.score == tempGame.score) {
                    tempGame = oneTry
                    tempActionSlice = snapshotActionSlice
                }
            }
            game = tempGame
            actionSlice = tempActionSlice
        }
        let score = game.score.addGreatPercent(LiveSimulationAdvanceOptionsManager.default.greatPercent)
        simulateResult.append(score)
        remainedLives.append(game.currentLife)
        callback?(LSResult(scores: simulateResult, remainedLives: remainedLives), game.logs)
    }
    func simulateOnce(options: LSOptions = [], callback: LSResultClosure? = nil) {
        let procedBonuses: [LSSkill]
        if options.contains(.optimistic) {
            procedBonuses = bonuses.sorted { $0.range.begin < $1.range.begin }
        } else if options.contains(.pessimistic) {
            procedBonuses = bonuses
                .filter { $0.rate1000000 >= 1000000 }
                .sorted { $0.range.begin < $1.range.begin }
        } else {
            procedBonuses = bonuses
                .filter { 1000000.proc($0.rate1000000)}
                .sorted { $0.range.begin < $1.range.begin }
        }
        var actions = [LSAction]()
        for (index, bonus) in procedBonuses.enumerated() {
            actions += [LSAction.skillStart(String(index), bonus), .skillEnd(String(index), bonus)]
        }
        actions += notes.map { LSAction.note($0) }
        actions.sort { ($0.timeOffset, $0.order) < ($1.timeOffset, $1.order) }
        let initialLife = options.contains(.doubleHP) ? 2 * totalLife : totalLife
        var game = LSGame(initialLife: initialLife, maxLife: 2 * totalLife, numberOfNotes: notes.count, difficulty: difficulty)
        game.afkMode = options.contains(.afk)
        game.shouldGenerateLogs = options.contains(.detailLog)
        for action in actions {
            game.perform(action)
        }
        let score = game.score.addGreatPercent(LiveSimulationAdvanceOptionsManager.default.greatPercent)
        simulateResult.append(score)
        remainedLives.append(game.currentLife)
        callback?(LSResult(scores: simulateResult, remainedLives: remainedLives), game.logs)
    }
    func wipeResults() {
        simulateResult.removeAll()
        remainedLives.removeAll()
    }
    func simulate(times: UInt, options: LSOptions = [], progress: CGSSProgressClosure = { _,_ in }, callback: @escaping LSResultClosure) {
        for i in 0..<times {
            if cancelled {
                cancelled = false
                break
            }
            simulateOnce(options: options)
            progress(Int(i + 1), Int(times))
        }
        let result = LSResult.init(scores: simulateResult, remainedLives: remainedLives)
        callback(result, [])
    }
    private var cancelled = false
    func cancelSimulating() {
        cancelled = true
    }
}
extension BidirectionalCollection {
    func last(
        where predicate: (Self.Iterator.Element) throws -> Bool
        ) rethrows -> Self.Iterator.Element? {
        for index in self.indices.reversed() {
            let element = self[index]
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
}
fileprivate let perfectRadius: [CGSSLiveDifficulty: [CGSSBeatmapNote.RangeType: Float]] = [
    .debut: [.click: 0.08, .slide: 0.2, .flick: 0.15],
    .regular: [.click: 0.08, .slide: 0.2, .flick: 0.15],
    .light: [.click: 0.08, .slide: 0.2, .flick: 0.15],
    .pro: [.click: 0.07, .slide: 0.2, .flick: 0.15],
    .master: [.click: 0.06, .slide: 0.2, .flick: 0.15],
    .masterPlus: [.click: 0.06, .slide: 0.2, .flick: 0.15],
    .legacyMasterPlus: [.click: 0.06, .slide: 0.2, .flick: 0.15],
    .trick: [.click: 0.06, .slide: 0.2, .flick: 0.15]
]
fileprivate let concentratedPerfectRadius: [CGSSLiveDifficulty: [CGSSBeatmapNote.RangeType: Float]] = [
    .debut: [.click: 0.05, .slide: 0.1, .flick: 0.1],
    .regular: [.click: 0.05, .slide: 0.1, .flick: 0.1],
    .light: [.click: 0.05, .slide: 0.1, .flick: 0.1],
    .pro: [.click: 0.04, .slide: 0.1, .flick: 0.1],
    .master: [.click: 0.03, .slide: 0.1, .flick: 0.1],
    .masterPlus: [.click: 0.03, .slide: 0.1, .flick: 0.1],
    .legacyMasterPlus: [.click: 0.03, .slide: 0.1, .flick: 0.1],
    .trick: [.click: 0.03, .slide: 0.1, .flick: 0.1]
]
private extension Int {
    func addGreatPercent(_ percent: Double) -> Int {
        return Int(round(Double(self) * (1 - 0.3 * percent / 100)))
    }
}
