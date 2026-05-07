// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Nested Types

    /// A single transition recorded in a Markov chain, expressed in terms of
    /// states.
    public struct Transition {

        // MARK: Public Instance Properties

        /// The source that precedes the target.
        public let source: Source

        /// The target that follows the source.
        public let target: Target

        /// The accumulated weight (observation count) for this transition.
        public let weight: UInt
    }
}

// MARK: - Equatable

extension MarkovChain.Transition: Equatable {
}

// MARK: - Sendable

extension MarkovChain.Transition: Sendable {
}
