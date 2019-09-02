import Foundation
struct LSOptions: OptionSet {
    let rawValue: UInt
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    static let optimistic = LSOptions(rawValue: 1 << 0)
    static let detailLog = LSOptions(rawValue: 1 << 1)
    static let afk = LSOptions(rawValue: 1 << 2)
    static let pessimistic = LSOptions(rawValue: 1 << 3)
    static let doubleHP = LSOptions(rawValue: 1 << 4)
}
