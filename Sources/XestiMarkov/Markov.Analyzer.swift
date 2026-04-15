// © 2026 John Gary Pusey (see LICENSE.md)

extension Markov {

    // MARK: Public Nested Types

    /// A type that analyzes sequences of events as observations and records
    /// them into a Markov chain.
    ///
    /// You can create an analyzer via ``Markov/analyzer()``. Call
    /// ``analyze(_:)`` one or more times to train the Markov chain on the
    /// provided event sequences.
    public struct Analyzer {

        // MARK: Public Instance Properties

        /// The Markov chain into which this analyzer records observations.
        public let markov: Markov
    }
}

// MARK: -

extension Markov.Analyzer {

    // MARK: Public Instance Methods

    /// Analyzes the provided event sequence as observations and records them
    /// into the Markov chain.
    ///
    /// - Parameter events:    The sequence of events to analyze.
    public func analyze(_ events: [Event]) {
        let states: [Markov.State] = events.map { .single($0) }

        _analyze0(states: states)

        let enhancedStates = [.begin] + states + [.end]

        _analyze1(states: enhancedStates)

        guard markov.maximumOrder > 1
        else { return }

        for order in 2...markov.maximumOrder {
            _analyzeN(states: enhancedStates,
                      order: order)
        }
    }

    // MARK: Private Instance Methods

    private func _analyze0(states: [Markov.State]) {
        for state in states {
            markov.increment(inState: .zero,
                             outState: state)
        }
    }

    private func _analyze1(states: [Markov.State]) {
        for idx in 0..<(states.count - 1) {
            let nextState = states[idx + 1]
            let currState = states[idx]

            if currState.canAppend(state: nextState) {
                markov.increment(inState: currState,
                                 outState: nextState)
            }
        }
    }

    private func _analyzeN(states: [Markov.State],
                           order: Int) {
        for idx in 0..<(states.count - order) {
            let nextIdx = idx + order
            let currState = _combineSlice(states: states[idx..<nextIdx])
            let nextState = states[nextIdx]

            if currState.canAppend(state: nextState) {
                markov.increment(inState: currState,
                                 outState: nextState)
            }
        }
    }

    private func _combineSlice(states: ArraySlice<Markov.State>) -> Markov.State {
        states.reduce(into: .zero) {
            $0.append(state: $1,
                      limit: states.count)
        }
    }
}
