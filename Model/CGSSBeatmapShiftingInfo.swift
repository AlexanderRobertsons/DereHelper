import UIKit
struct BpmShiftingPoint {    
    var bpm: Int
    var timestamp: Float
}
struct BpmShiftingRange {
    var start: Float
    var length: Float {
        return end - start
    }
    var end: Float
    var bpm: Int
    var beginPoint: BpmShiftingPoint {
        return BpmShiftingPoint.init(bpm: bpm, timestamp: start)
    }
}
extension CGSSBeatmapNote {
    func inRange(range: BpmShiftingRange) -> Bool {
        if sec >= range.start && sec < range.end {
            return true
        } else {
            return false
        }
    }
}
struct CGSSBeatmapShiftingInfo {
    var shiftingPoints = [BpmShiftingPoint]()
    var shiftingRanges = [BpmShiftingRange]()
    var offset: Float
    init(info: NSDictionary) {
        let timestampStrings = info.value(forKey: "timestamps") as? [String] ?? []
        let start = Float(info.value(forKey: "start") as? Double ?? 0)
        offset = Float(info.value(forKey: "offset") as? Double ?? 0)
        for subString in timestampStrings {
            let value = subString.components(separatedBy: ",")
            let shiftingPoint = BpmShiftingPoint(bpm: Int(value[1])!, timestamp: Float(value[0])! + start)
            if let lastPoint = shiftingPoints.last {
                let shiftingRange = BpmShiftingRange(start: lastPoint.timestamp, end: shiftingPoint.timestamp, bpm: lastPoint.bpm)
                shiftingRanges.append(shiftingRange)
            }
            shiftingPoints.append(shiftingPoint)
        }
        if let lastPoint = shiftingPoints.last {
            let shiftingRange = BpmShiftingRange(start: lastPoint.timestamp, end: Float.infinity, bpm: lastPoint.bpm)
            shiftingRanges.append(shiftingRange)
        }
    }
}
