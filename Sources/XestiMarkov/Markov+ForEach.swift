// © 2026 John Gary Pusey (see LICENSE.md)

extension Markov {

    // MARK: Public Instance Methods

    /// Calls the given closure for each transition recorded in the Markov
    /// chain.
    ///
    /// The closure receives the input state, the output state, and the
    /// accumulated weight of that transition. Transitions are visited in a
    /// consistent, sorted order.
    ///
    /// - Parameter body:   A closure that accepts an input state, an output
    ///                     state, and a transition weight.
    public func forEach(_ body: (State, State, UInt) -> Void) {
        let ss = snapshot

        for inState in ss.inStateMap.stateToElement.sorted() {
            let pairs = _possibleOutStates(after: inState,
                                           inStateMap: ss.inStateMap,
                                           outStateMap: ss.outStateMap,
                                           accumulator: ss.accumulator)

            for pair in pairs {
                body(inState,
                     pair.outState,
                     pair.weight)
            }
        }
    }

    // MARK: Private Nested Types

    private typealias OutPair = (outState: State, weight: UInt)

    // MARK: Private Instance Methods

    private func _possibleOutStates(after inState: State,
                                    inStateMap: StateMap<State>,
                                    outStateMap: StateMap<State>,
                                    accumulator: Accumulator) -> [OutPair] {
        guard let simpleInState = inStateMap[inState]
        else { return [] }

        let elements = accumulator.extractElements(for: simpleInState)

        return elements.compactMap {
            guard let outState = outStateMap[$0.key.outState]
            else { return nil }

            return (outState, $0.value)
        }.sorted { $0.outState < $1.outState }
    }
}
