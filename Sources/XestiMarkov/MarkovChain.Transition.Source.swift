// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain.Transition {

    // MARK: Public Nested Types

    /// The source (input side) of a Markov chain transition — the preceding
    /// state context.
    public enum Source {
        /// The implicit start of a sequence.
        case begin

        /// One or more preceding states. A one-element array indicates a
        /// first-order transition; a multi-element array indicates a
        /// higher-order transition, with states in chronological order.
        case states([State])

        /// Zeroth-order source: no history. Used to model overall state
        /// frequency independent of position.
        case zero
    }
}

// MARK: - Equatable

extension MarkovChain.Transition.Source: Equatable {
}

// MARK: - Sendable

extension MarkovChain.Transition.Source: Sendable {
}
