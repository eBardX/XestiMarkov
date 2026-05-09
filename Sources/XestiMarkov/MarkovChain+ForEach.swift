// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Calls the given closure for each transition recorded in this Markov
    /// chain.
    ///
    /// Transitions are visited in a consistent, sorted order.
    ///
    /// - Parameter body:   A closure that accepts a ``Transition``.
    public func forEach(_ body: (Transition) -> Void) {
        let ss = snapshot

        for inContext in ss.inContextMap.indexToElement.sorted() {
            let pairs = _possibleOutContexts(after: inContext,
                                             inContextMap: ss.inContextMap,
                                             outContextMap: ss.outContextMap,
                                             accumulator: ss.accumulator)

            for pair in pairs {
                guard let transition = _makeTransition(inContext: inContext,
                                                       outContext: pair.outContext,
                                                       weight: pair.weight)
                else { continue }

                body(transition)
            }
        }
    }

    // MARK: Private Type Aliases

    private typealias OutPair = (outContext: Context<State>, weight: UInt)

    // MARK: Private Instance Methods

    private func _makeTransition(inContext: Context<State>,
                                 outContext: Context<State>,
                                 weight: UInt) -> Transition? {
        guard let source = _source(for: inContext),
              let target = _target(for: outContext)
        else { return nil }

        return Transition(source: source,
                          target: target,
                          weight: weight)
    }

    private func _possibleOutContexts(after inContext: Context<State>,
                                      inContextMap: IndexMap<Context<State>>,
                                      outContextMap: IndexMap<Context<State>>,
                                      accumulator: Accumulator) -> [OutPair] {
        guard let simpleInIndex = inContextMap[inContext]
        else { return [] }

        let elements = accumulator.extractElements(for: simpleInIndex)

        return elements.compactMap {
            guard let outContext = outContextMap[$0.key.outIndex]
            else { return nil }

            return (outContext, $0.value)
        }.sorted { $0.outContext < $1.outContext }
    }

    private func _source(for context: Context<State>) -> Transition.Source? {
        switch context {
        case .zero:
            return .zero

        case .begin:
            return .begin

        case let .single(state):
            return .states([state])

        case let .sequence(seq):
            let states = seq.compactMap {
                if case let .single(s) = $0 { s } else { nil }
            }
            return states.isEmpty ? nil : .states(states)

        case .end:
            return nil
        }
    }

    private func _target(for context: Context<State>) -> Transition.Target? {
        switch context {
        case let .single(state):
                .state(state)

        case .end:
                .end

        default:
            nil
        }
    }
}
