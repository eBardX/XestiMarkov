// © 2026 John Gary Pusey (see LICENSE.md)

@testable import XestiMarkov

internal struct MockRandomNumberGenerator: RandomNumberGenerator {

    // MARK: Internal Initializers

    internal init(seed: UInt64 = 0,
                  increment: UInt64 = 1) {
        self.current = seed
        self.increment = max(increment, 1)
    }

    // MARK: Private Instance Properties

    private let increment: UInt64

    private var current: UInt64
}

// MARK: -

extension MockRandomNumberGenerator {

    // MARK: Internal Instance Methods

    internal mutating func next() -> UInt64 {
        defer { current = current &+ increment }

        return current
    }
}

// MARK: - Sendable

extension MockRandomNumberGenerator: Sendable {
}
