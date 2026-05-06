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

    /// Generates a sequence of states until the given predicate returns `true`.
    ///
    /// Generation stops when `predicate` returns `true` for a generated state
    /// or when the Markov chain reaches a terminal state, whichever comes
    /// first. The state that triggers the predicate is included in the result.
    ///
    /// For a zeroth-order generator, only the predicate can stop generation;
    /// there are no terminal states at order zero.
    ///
    /// - Parameter predicate:  The closure to call with each generated state.
    ///                         Return `true` to stop generation.
    ///
    /// - Returns:  An array of generated states. The final state satisfies
    ///             `predicate` if that is what stopped generation.
    public mutating func generate(until predicate: (State) -> Bool) -> [State] {
        if order > 0 {
            _generateN(until: predicate)
        } else {
            _generate0(until: predicate)
        }
    }

    /// Generates the next state following the given predecessor sequence.
    ///
    /// The `states` parameter represents the most recently generated states.
    /// Pass an empty array (or omit it) to generate the first state of a new
    /// sequence. Only the last ``order`` elements of `states` are considered.
    ///
    /// Returns `nil` if no transition is recorded from the given context, or if
    /// the chain would transition to a terminal state.
    ///
    /// - Parameter states: The preceding states that form the generation
    ///                     context. Defaults to `[]`.
    ///
    /// - Returns:  The next generated state, or `nil` if generation cannot
    ///             continue from the given context.
    public mutating func next(after states: [State] = []) -> State? {
        let context = _context(for: states)

        guard let nextContext = _next(after: context),
              case let .single(state) = nextContext
        else { return nil }

        return state
    }

    // MARK: Private Instance Methods

    private func _context(for states: [State]) -> Context<State> {
        guard order > 0
        else { return .zero }

        guard !states.isEmpty
        else { return .begin }

        var context: Context<State> = .begin

        for state in states.suffix(order) {
            context.append(context: .single(state),
                           limit: order)
        }

        return context
    }

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

    private mutating func _generate0(until predicate: (State) -> Bool) -> [State] {
        var states: [State] = []

        while true {
            guard let nextContext = _next(after: .zero),
                  case let .single(state) = nextContext
            else { break }

            states.append(state)

            guard !predicate(state)
            else { break }
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

    private mutating func _generateN(until predicate: (State) -> Bool) -> [State] {
        var prevContext: Context<State> = .begin
        var states: [State] = []

        while true {
            guard prevContext.hasNext,
                  let nextContext = _next(after: prevContext),
                  case let .single(state) = nextContext
            else { break }

            states.append(state)

            guard !predicate(state)
            else { break }

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
