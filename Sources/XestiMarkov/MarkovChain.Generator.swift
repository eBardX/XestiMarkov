// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Nested Types

    /// A type that generates state sequences based on the probabilities learned
    /// by a Markov chain.
    ///
    /// You can create a generator via ``MarkovChain/generator(order:)``. The
    /// generator operates on a _snapshot_ of the Markov chain taken at creation
    /// time, so subsequent training does not affect an existing generator.
    public struct Generator {

        // MARK: Public Instance Properties

        /// The number of preceding states used as context when selecting the
        /// next state. A value of zero means that states are chosen by
        /// frequency alone, with no history.
        public let order: Int

        // MARK: Internal Initializers

        internal init?(markovChain: MarkovChain,
                       order: Int,
                       rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
            guard (0...markovChain.maximumOrder) ~= order
            else { return nil }

            let ss = markovChain.snapshot

            self.inContextMap = ss.inContextMap
            self.outContextMap = ss.outContextMap
            self.order = order
            self.simpleMarkovChain = SimpleMarkovChain(accumulator: ss.accumulator,
                                                       rng: rng)
        }

        // MARK: Private Instance Properties

        private let inContextMap: IndexMap<Context<State>>
        private let outContextMap: IndexMap<Context<State>>

        private var simpleMarkovChain: SimpleMarkovChain
    }
}

// MARK: -

extension MarkovChain.Generator {

    // MARK: Public Instance Methods

    /// Generates a sequence of states up to the given limit.
    ///
    /// Generation stops when the Markov chain reaches a terminal state or when
    /// `limit` states have been produced, whichever comes first. If `limit` is
    /// less than or equal to zero, an empty array is returned immediately.
    ///
    /// - Parameter limit:   The maximum number of states to generate.
    ///
    /// - Returns:  An array of generated states, which may be shorter than
    ///             `limit` if the Markov chain reaches a terminal state.
    public mutating func generate(limit: Int) -> [State] {
        guard limit > 0
        else { return [] }

        return if order > 0 {
            _generateN(limit)
        } else {
            _generate0(limit)
        }
    }

    // MARK: Private Instance Methods

    private mutating func _generate0(_ limit: Int) -> [State] {
        var states: [State] = []

        for _ in (0..<limit) {
            guard let nextContext = _next(after: .zero),
                  case let .single(state) = nextContext
            else { break }

            states.append(state)
        }

        return states
    }

    private mutating func _generateN(_ limit: Int) -> [State] {
        var prevContext: Context<State> = .begin
        var states: [State] = []

        for _ in (0..<limit) {
            guard prevContext.hasNext,
                  let nextContext = _next(after: prevContext),
                  case let .single(state) = nextContext
            else { break }

            states.append(state)

            prevContext.append(context: nextContext,
                               limit: order)
        }

        return states
    }

    private mutating func _next(after inContext: Context<State>) -> Context<State>? {
        guard let simpleInIndex = inContextMap[inContext],
              let simpleOutIndex = simpleMarkovChain.next(after: simpleInIndex)
        else { return nil }

        return outContextMap[simpleOutIndex]
    }
}
