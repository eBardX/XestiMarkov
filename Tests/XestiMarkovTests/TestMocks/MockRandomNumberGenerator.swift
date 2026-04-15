// © 2026 John Gary Pusey (see LICENSE.md)

@testable import XestiMarkov

internal struct MockRandomNumberGenerator: RandomNumberGenerator {
    internal init(seed: UInt64 = 0,
                  increment: UInt64 = 1) {
        self.current = seed
        self.increment = max(increment, 1)
    }

    internal mutating func next() -> UInt64 {
        defer { current = current &+ increment }

        return current
    }

    private var current: UInt64
    private let increment: UInt64
}

// MARK: - Sendable

extension MockRandomNumberGenerator: Sendable {
}
