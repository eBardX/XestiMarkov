// © 2026 John Gary Pusey (see LICENSE.md)

extension Markov {

    // MARK: Public Nested Types

    /// A type that generates event sequences based on the probabilities learned
    /// by a Markov chain.
    ///
    /// You can create a generator via ``Markov/generator(order:)``. The
    /// generator operates on a _snapshot_ of the Markov chain taken at creation
    /// time, so subsequent training does not affect an existing generator.
    public struct Generator {

        // MARK: Public Instance Properties

        /// The number of preceding events used as context when selecting the
        /// next event. A value of zero means that events are chosen by
        /// frequency alone, with no history.
        public let order: Int

        // MARK: Internal Initializers

        internal init?(markov: Markov,
                       order: Int,
                       rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
            guard (0...markov.maximumOrder) ~= order
            else { return nil }

            let ss = markov.snapshot

            self.inStateMap = ss.inStateMap
            self.outStateMap = ss.outStateMap
            self.order = order
            self.simpleMarkov = SimpleMarkov(accumulator: ss.accumulator,
                                             rng: rng)
        }

        // MARK: Private Instance Properties

        private let inStateMap: StateMap<State>
        private let outStateMap: StateMap<State>

        private var simpleMarkov: SimpleMarkov
    }
}

// MARK: -

extension Markov.Generator {

    // MARK: Public Instance Methods

    /// Generates a sequence of events up to the given limit.
    ///
    /// Generation stops when the Markov chain reaches a terminal state or when
    /// `limit` events have been produced, whichever comes first. If `limit` is
    /// less than or equal to zero, an empty array is returned immediately.
    ///
    /// - Parameter limit:   The maximum number of events to generate.
    ///
    /// - Returns:  An array of generated events, which may be shorter than
    ///             `limit` if the Markov chain reaches a terminal state.
    public mutating func generate(limit: Int) -> [Event] {
        guard limit > 0
        else { return [] }

        return if order > 0 {
            _generateN(limit)
        } else {
            _generate0(limit)
        }
    }

    // MARK: Private Instance Methods

    private mutating func _generate0(_ limit: Int) -> [Event] {
        var events: [Event] = []

        for _ in (0..<limit) {
            guard let nextState = _next(after: .zero),
                  case let .single(event) = nextState
            else { break }

            events.append(event)
        }

        return events
    }

    private mutating func _generateN(_ limit: Int) -> [Event] {
        var prevState: Markov.State = .begin
        var events: [Event] = []

        for _ in (0..<limit) {
            guard prevState.hasNext,
                  let nextState = _next(after: prevState),
                  case let .single(event) = nextState
            else { break }

            events.append(event)

            prevState.append(state: nextState,
                             limit: order)
        }

        return events
    }

    private mutating func _next(after inState: Markov.State) -> Markov.State? {
        guard let simpleInState = inStateMap[inState],
              let simpleOutState = simpleMarkov.next(after: simpleInState)
        else { return nil }

        return outStateMap[simpleOutState]
    }
}
