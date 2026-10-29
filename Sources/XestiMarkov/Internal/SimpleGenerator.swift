// © 2026 John Gary Pusey (see LICENSE.md)

internal struct SimpleGenerator<State> where State: Codable,
                                             State: Comparable,
                                             State: Hashable,
                                             State: Sendable {

    // MARK: Internal Initializers

    internal init?(markovChain: MarkovChain<State>,
                   order: Int,
                   startsAtBegin: Bool = true,
                   stopsAtEnd: Bool = true,
                   rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
        guard (0...markovChain.maximumOrder) ~= order
        else { return nil }

        let ss = markovChain.snapshot

        self.accumulator = ss.accumulator
        self.excludedOutIndex = stopsAtEnd ? nil : ss.outContextMap[.end]
        self.inContextMap = ss.inContextMap
        self.order = order
        self.outContextMap = ss.outContextMap
        self.simpleMarkovChain = SimpleMarkovChain(accumulator: ss.accumulator,
                                                   rng: rng)
        self.startsAtBegin = startsAtBegin
        self.stopsAtEnd = stopsAtEnd
    }

    // MARK: Internal Instance Properties

    internal let order: Int
    internal let startsAtBegin: Bool
    internal let stopsAtEnd: Bool

    // MARK: Private Instance Properties

    private let accumulator: Accumulator
    private let excludedOutIndex: Int?
    private let inContextMap: IndexMap<Context<State>>
    private let outContextMap: IndexMap<Context<State>>

    private var simpleMarkovChain: SimpleMarkovChain
}

// MARK: -

extension SimpleGenerator {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Instance Methods

    internal mutating func generate(continuing states: [State],
                                    until predicate: (State) -> Bool) -> [State] {
        _generate(continuing: states,
                  limit: nil,
                  until: predicate)
    }

    internal mutating func generate(continuing states: [State],
                                    upTo limit: Int) -> [State] {
        guard limit > 0
        else { return [] }

        return _generate(continuing: states,
                         limit: limit) { _ in false }
    }

    internal mutating func next(after states: [State]) -> State? {
        let context = _context(for: states,
                               anchored: startsAtBegin)

        guard let nextContext = _next(after: context),
              case let .single(state) = nextContext
        else { return nil }

        return state
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        let context: Context<State> = switch source {
        case .begin:
            _context(for: [],
                     anchored: startsAtBegin)

        case let .beginStates(states):
            _context(for: states,
                     anchored: true)

        case let .states(states):
            _context(for: states,
                     anchored: startsAtBegin)

        case .zero:
            .zero
        }

        guard let inIndex = _inIndex(for: context)
        else { return [] }

        let distribution: [WeightedTarget] = accumulator.extractElements(for: inIndex).compactMap { element in
            guard element.key.outIndex != excludedOutIndex,
                  let outContext = outContextMap[element.key.outIndex]
            else { return nil }

            switch outContext {
            case .end:
                return (target: .end,
                        weight: Double(element.value))

            case let .single(state):
                return (target: .state(state),
                        weight: Double(element.value))

            default:
                return nil
            }
        }

        return sortByTarget(distribution)
    }

    // MARK: Private Instance Methods

    //
    // Builds the context in which to choose the state that follows `states`.
    // An anchored context begins at `.begin` (so a history shorter than the
    // order is treated as the opening of a sequence); an unanchored one
    // begins at `.zero` (so the first state is chosen by frequency, and a
    // short history uses a shorter context).
    //
    private func _context(for states: [State],
                          anchored: Bool) -> Context<State> {
        var context: Context<State> = order > 0 && anchored ? .begin : .zero

        for state in states.suffix(order) {
            context.append(context: .single(state),
                           limit: order)
        }

        return context
    }

    private mutating func _generate(continuing states: [State],
                                    limit: Int?,
                                    until predicate: (State) -> Bool) -> [State] {
        var prevContext = _context(for: states,
                                   anchored: startsAtBegin)
        var result: [State] = []

        while limit.map({ result.count < $0 }) ?? true {
            guard prevContext.hasNext,
                  let nextContext = _next(after: prevContext),
                  case let .single(state) = nextContext
            else { break }

            result.append(state)

            guard !predicate(state)
            else { break }

            prevContext.append(context: nextContext,
                               limit: order)
        }

        return result
    }

    //
    // Returns the index of the context from which to choose the next state.
    // When `.end` is excluded, a context whose only successor is `.end` (or a
    // context never observed) backs off to successively shorter contexts,
    // down to `.zero`.
    //
    private func _inIndex(for context: Context<State>) -> Int? {
        var context = context

        while true {
            if let inIndex = inContextMap[context],
               simpleMarkovChain.totalWeight(after: inIndex,
                                             excluding: excludedOutIndex) > 0 {
                return inIndex
            }

            guard !stopsAtEnd,
                  let shorterContext = context.shortened
            else { return nil }

            context = shorterContext
        }
    }

    private mutating func _next(after inContext: Context<State>) -> Context<State>? {
        guard let inIndex = _inIndex(for: inContext),
              let outIndex = simpleMarkovChain.next(after: inIndex,
                                                    excluding: excludedOutIndex)
        else { return nil }

        return outContextMap[outIndex]
    }
}

// MARK: - MarkovChain.Generator

extension SimpleGenerator: MarkovChain<State>.Generator {
}
