// © 2026 John Gary Pusey (see LICENSE.md)

@testable import XestiMarkov

internal typealias ExtractPair   = Dictionary<Accumulator.Key, UInt>.Element
internal typealias ExtractResult = [ExtractPair]

// swiftlint:disable:next static_operator
internal func < (lhs: ExtractPair,
                 rhs: ExtractPair) -> Bool {
    guard lhs.key != rhs.key
    else { return lhs.value < rhs.value }

    return lhs.key < rhs.key
}

// swiftlint:disable:next static_operator
internal func == (lhs: ExtractResult,
                  rhs: ExtractResult) -> Bool {
    guard lhs.count == rhs.count
    else { return false }

    let lhsSorted = lhs.sorted { $0 < $1 }
    let rhsSorted = rhs.sorted { $0 < $1 }

    for pair in zip(lhsSorted, rhsSorted) where pair.0.key != pair.1.key || pair.0.value != pair.1.value {
        return false
    }

    return true
}
