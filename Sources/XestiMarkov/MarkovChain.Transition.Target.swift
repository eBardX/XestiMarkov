// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain.Transition {

    // MARK: Public Nested Types

    /// The target (output side) of a Markov chain transition — the resulting
    /// state or sequence end.
    public enum Target {
        /// The implicit end of the sequence.
        case end

        /// The next state in the sequence.
        case state(State)
    }
}

// MARK: - Equatable

extension MarkovChain.Transition.Target: Equatable {
}

// MARK: - Hashable

extension MarkovChain.Transition.Target: Hashable {
}

// MARK: - Sendable

extension MarkovChain.Transition.Target: Sendable {
}
