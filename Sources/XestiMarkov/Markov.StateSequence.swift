// © 2026 John Gary Pusey (see LICENSE.md)

extension Markov {

    // MARK: Public Nested Types

    /// An ordered sequence of states representing higher-order context within a
    /// Markov chain.
    public struct StateSequence: Sequence {

        // MARK: Public Instance Properties

        /// The ordered array of states that make up this sequence.
        public private(set) var states: [State]

        // MARK: Internal Initializers

        internal init() {
            self.states = []
        }
    }
}

// MARK: -

extension Markov.StateSequence {

    // MARK: Public Instance Methods

    /// Returns an iterator over the states in this sequence.
    ///
    /// - Returns:  An iterator over the elements of ``states``.
    @inlinable
    public func makeIterator() -> IndexingIterator<[Markov.State]> {
        states.makeIterator()
    }

    // MARK: Internal Instance Properties

    @inlinable internal var count: Int {
        states.count
    }

    @inlinable internal var last: Markov.State? {
        states.last
    }

    // MARK: Internal Instance Methods

    internal mutating func append(state: Markov.State,
                                  limit: Int) {
        let lastState = states.last ?? .zero

        switch (lastState, state) {
        case (.begin, .begin),
            (.single, .begin),
            (.end, _),
            (_, .sequence),
            (_, .zero):
            break

        case (.zero, _):
            states = [state]

        default:
            states.append(state)
        }

        if states.count > limit {
            states = Array(states.suffix(limit))
        }
    }

    // MARK: Internal Subscripts

    @inlinable
    internal subscript(index: Int) -> Markov.State {
        states[index]
    }
}

// MARK: - Codable

extension Markov.StateSequence: Codable {
}

// MARK: - Comparable

extension Markov.StateSequence: Comparable {
    public static func < (lhs: Self,
                          rhs: Self) -> Bool {
        lhs.states.lexicographicallyPrecedes(rhs.states)
    }
}

// MARK: - Hashable

extension Markov.StateSequence: Hashable {
}

// MARK: - Sendable

extension Markov.StateSequence: Sendable {
}
