// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that generates state sequences from the probability distribution
/// learned by a Markov chain.
///
/// Obtain a generator through
/// ``MarkovChain/generator(order:startsAtBegin:stopsAtEnd:using:)`` or one of
/// the static factory methods on ``MarkovChain``. A generator operates on a
/// snapshot of the chain taken at creation time; subsequent training does not
/// affect an existing generator.
///
/// Prefer the ``MarkovChain/Generator`` type alias; write `any
/// MarkovChain<State>.Generator` rather than `any MarkovChainGenerator<State>`
/// directly.
public protocol MarkovChainGenerator<State>: Sendable {

    // MARK: Public Associated Types

    /// The type of state produced by this generator.
    associatedtype State: Codable & Comparable & Hashable & Sendable

    // MARK: Public Type Aliases

    /// The type used to identify the source of a transition.
    typealias Source = MarkovChain<State>.Transition.Source

    /// The type used to identify the target of a transition.
    typealias Target = MarkovChain<State>.Transition.Target

    /// A transition target paired with its relative weight.
    typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Public Instance Methods

    /// Generates a sequence of states that continues the given states, until
    /// the given predicate returns `true`.
    ///
    /// The given states form the initial context, as if they had already been
    /// generated; they are not included in the result. Generation stops when
    /// `predicate` returns `true` or the chain reaches a terminal state,
    /// whichever comes first. The triggering state is included in the result.
    ///
    /// - Parameter states:     The preceding states to continue.
    /// - Parameter predicate:  Called with each generated state. Return `true`
    ///                         to stop generation.
    ///
    /// - Returns:  An array of newly generated states.
    mutating func generate(continuing states: [State],
                           until predicate: (State) -> Bool) -> [State]

    /// Generates a sequence of states that continues the given states, up to
    /// the given limit.
    ///
    /// The given states form the initial context, as if they had already been
    /// generated; they are not included in the result. Generation stops when
    /// the chain reaches a terminal state or when `limit` new states have been
    /// produced, whichever comes first. Returns an empty array when `limit` is
    /// less than or equal to zero.
    ///
    /// - Parameter states: The preceding states to continue.
    /// - Parameter limit:  The maximum number of states to generate.
    ///
    /// - Returns:  An array of newly generated states, possibly shorter than
    ///             `limit`.
    mutating func generate(continuing states: [State],
                           upTo limit: Int) -> [State]

    /// Generates a sequence of states until the given predicate returns `true`.
    ///
    /// Generation stops when `predicate` returns `true` or the chain reaches a
    /// terminal state, whichever comes first. The triggering state is included
    /// in the result.
    ///
    /// - Parameter predicate:  Called with each generated state. Return `true`
    ///                         to stop generation.
    ///
    /// - Returns:  An array of generated states.
    mutating func generate(until predicate: (State) -> Bool) -> [State]

    /// Generates a sequence of states up to the given limit.
    ///
    /// Generation stops when the chain reaches a terminal state or when `limit`
    /// states have been produced, whichever comes first. Returns an empty array
    /// when `limit` is less than or equal to zero.
    ///
    /// - Parameter limit:  The maximum number of states to generate.
    ///
    /// - Returns:  An array of generated states, possibly shorter than `limit`.
    mutating func generate(upTo limit: Int) -> [State]

    /// Generates the next state following the given predecessor sequence.
    ///
    /// The `states` parameter represents the most recently generated states.
    /// Pass an empty array to generate the first state of a new sequence. Only
    /// the most recent context elements are considered.
    ///
    /// Returns `nil` when no transition is recorded for the given context or
    /// when the chain would transition to a terminal state.
    ///
    /// - Parameter states:  The preceding states that form the generation
    ///                      context.
    ///
    /// - Returns:  The next state, or `nil` if generation cannot continue.
    mutating func next(after states: [State]) -> State?

    /// Returns the weighted distribution of transitions following the given
    /// source.
    ///
    /// Each element pairs a ``MarkovChain/Transition/Target`` with an
    /// unnormalized relative weight. An empty array indicates no transitions
    /// are recorded for the given source.
    ///
    /// - Parameter source:  The transition source whose outgoing distribution
    ///                      to return.
    ///
    /// - Returns:  `(target, weight)` pairs, or `[]` if no transitions exist.
    func weights(after source: Source) -> [WeightedTarget]
}

// MARK: -

extension MarkovChainGenerator {

    // MARK: Public Instance Methods

    /// Generates a sequence of states that continues the given states, until
    /// the given predicate returns `true`.
    ///
    /// This default implementation tracks the accumulated history, starting
    /// with `states`, and calls ``next(after:)`` at each step until
    /// `predicate` returns `true`.
    ///
    /// - Parameter states:     The preceding states to continue.
    /// - Parameter predicate:  Called with each generated state. Return `true`
    ///                         to stop generation.
    ///
    /// - Returns:  An array of newly generated states.
    public mutating func generate(continuing states: [State],
                                  until predicate: (State) -> Bool) -> [State] {
        var history = states
        var result: [State] = []

        while true {
            guard let state = next(after: history)
            else { break }

            history.append(state)
            result.append(state)

            if predicate(state) {
                break
            }
        }

        return result
    }

    /// Generates a sequence of states that continues the given states, up to
    /// the given limit.
    ///
    /// This default implementation tracks the accumulated history, starting
    /// with `states`, and calls ``next(after:)`` at each step.
    ///
    /// - Parameter states: The preceding states to continue.
    /// - Parameter limit:  The maximum number of states to generate.
    ///
    /// - Returns:  An array of newly generated states, possibly shorter than
    ///             `limit`.
    public mutating func generate(continuing states: [State],
                                  upTo limit: Int) -> [State] {
        guard limit > 0
        else { return [] }

        var history = states
        var result: [State] = []

        for _ in 0..<limit {
            guard let state = next(after: history)
            else { break }

            history.append(state)
            result.append(state)
        }

        return result
    }

    /// Generates a sequence of states until the given predicate returns `true`.
    ///
    /// This default implementation is equivalent to calling
    /// ``generate(continuing:until:)`` with no preceding states.
    ///
    /// - Parameter predicate:  Called with each generated state. Return `true`
    ///                         to stop generation.
    ///
    /// - Returns:  An array of generated states.
    public mutating func generate(until predicate: (State) -> Bool) -> [State] {
        generate(continuing: [],
                 until: predicate)
    }

    /// Generates a sequence of states up to the given limit.
    ///
    /// This default implementation is equivalent to calling
    /// ``generate(continuing:upTo:)`` with no preceding states.
    ///
    /// - Parameter limit:  The maximum number of states to generate.
    ///
    /// - Returns:  An array of generated states, possibly shorter than `limit`.
    public mutating func generate(upTo limit: Int) -> [State] {
        generate(continuing: [],
                 upTo: limit)
    }

    /// Generates the next state from the beginning of a new sequence.
    ///
    /// Convenience overload of ``next(after:)`` that passes an empty
    /// predecessor array, equivalent to calling `next(after: [])`.
    ///
    /// - Returns:  The next state, or `nil` if generation cannot begin.
    public mutating func next() -> State? {
        next(after: [])
    }
}
