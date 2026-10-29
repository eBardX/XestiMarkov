// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain.Transition {

    // MARK: Public Nested Types

    /// The source (input side) of a Markov chain transition — the preceding
    /// state context.
    public enum Source {
        /// The implicit start of the sequence.
        case begin

        /// The implicit start of the sequence, followed by one or more states
        /// in chronological order. This is a context near the start of a
        /// sequence, shorter than the order at which it was recorded; for
        /// example, `.beginStates([s1])` is the second-order context in which
        /// `s1` opened a sequence.
        case beginStates([State])

        /// One or more preceding states. A one-element array indicates a
        /// first-order transition; a multi-element array indicates a
        /// higher-order transition, with states in chronological order.
        case states([State])

        /// Zeroth-order source: no history. Used to model overall state
        /// frequency independent of position.
        case zero
    }
}

// MARK: -

extension MarkovChain.Transition.Source {

    // MARK: Public Instance Properties

    /// The order of this source: the number of preceding elements, counting
    /// the implicit start of the sequence as one.
    public var order: Int {
        switch self {
        case .begin:
            1

        case let .beginStates(states):
            states.count + 1

        case let .states(states):
            states.count

        case .zero:
            0
        }
    }
}

// MARK: - Equatable

extension MarkovChain.Transition.Source: Equatable {
}

// MARK: - Sendable

extension MarkovChain.Transition.Source: Sendable {
}
