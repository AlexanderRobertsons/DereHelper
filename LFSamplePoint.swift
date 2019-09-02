import Foundation
struct LFSamplePoint<T> {
    var probability: Double {
        didSet {
            assert(probability <= 1 || probability >= 0)
        }
    }
    var value: T
}
