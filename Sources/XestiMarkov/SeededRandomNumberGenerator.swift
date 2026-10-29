// © 2026 John Gary Pusey (see LICENSE.md)

/// A random number generator that produces a reproducible sequence of values
/// from a seed.
///
/// Two instances created with the same seed produce the same sequence. Pass
/// one to a generator factory such as ``MarkovChain/generator(order:startsAtBegin:stopsAtEnd:using:)``
/// to make generation reproducible: the same chain, options and seed always
/// generate the same states.
///
/// This generator uses the SplitMix64 algorithm. It is fast and statistically
/// sound for sampling, but it is not cryptographically secure.
public struct SeededRandomNumberGenerator {

    // MARK: Public Initializers

    /// Creates a new random number generator with the given seed.
    ///
    /// - Parameter seed:   The seed from which to produce values.
    public init(seed: UInt64) {
        self.state = seed
    }

    // MARK: Private Instance Properties

    private var state: UInt64
}

// MARK: - RandomNumberGenerator

extension SeededRandomNumberGenerator: RandomNumberGenerator {

    // MARK: Public Instance Methods

    /// Returns the next value in this generator’s sequence.
    ///
    /// - Returns:  A pseudorandom 64-bit value.
    public mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15

        var z = state

        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb

        return z ^ (z >> 31)
    }
}

// MARK: - Sendable

extension SeededRandomNumberGenerator: Sendable {
}
