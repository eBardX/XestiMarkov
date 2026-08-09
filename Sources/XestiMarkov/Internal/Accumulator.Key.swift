// © 2026 John Gary Pusey (see LICENSE.md)

extension Accumulator {

    // MARK: Internal Nested Types

    internal struct Key {

        // MARK: Internal Instance Properties

        internal let inIndex: Int
        internal let outIndex: Int
    }
}

// MARK: - Comparable

extension Accumulator.Key: Comparable {
    internal static func < (lhs: Self,
                            rhs: Self) -> Bool {
        (lhs.inIndex, lhs.outIndex) < (rhs.inIndex, rhs.outIndex)
    }
}

// MARK: - Hashable

extension Accumulator.Key: Hashable {
}

// MARK: - Sendable

extension Accumulator.Key: Sendable {
}
