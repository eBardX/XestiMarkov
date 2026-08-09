// © 2026 John Gary Pusey (see LICENSE.md)

internal struct AnyRandomNumberGenerator {

    // MARK: Internal Initializers

    @inlinable
    internal init(_ rng: some (RandomNumberGenerator & Sendable)) {
        self.rng = rng
    }

    // MARK: Internal Instance Properties

    @usableFromInline internal var rng: any (RandomNumberGenerator & Sendable)
}

// MARK: -

extension AnyRandomNumberGenerator {

    // MARK: Internal Instance Methods

    @inlinable
    internal mutating func next() -> UInt64 {
        rng.next()
    }
}

// MARK: - RandomNumberGenerator

extension AnyRandomNumberGenerator: RandomNumberGenerator {
}

// MARK: - Sendable

extension AnyRandomNumberGenerator: Sendable {
}
