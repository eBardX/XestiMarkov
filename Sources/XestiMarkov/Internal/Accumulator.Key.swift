// © 2026 John Gary Pusey (see LICENSE.md)

extension Accumulator {

    // MARK: Internal Nested Types

    internal struct Key: Hashable {

        // MARK: Internal Instance Properties

        internal let inState: Int
        internal let outState: Int
    }
}

// MARK: - Comparable

extension Accumulator.Key: Comparable {
    internal static func < (lhs: Self,
                            rhs: Self) -> Bool {
        (lhs.inState, lhs.outState) < (rhs.inState, rhs.outState)
    }
}

// MARK: - Sendable

extension Accumulator.Key: Sendable {
}
