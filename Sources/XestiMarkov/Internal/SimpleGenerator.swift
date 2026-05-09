// © 2026 John Gary Pusey (see LICENSE.md)

internal struct SimpleGenerator<State> where State: Codable,
                                             State: Comparable,
                                             State: Hashable,
                                             State: Sendable {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Initializers

    internal init?(markovChain: MarkovChain<State>,
                   order: Int,
                   rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
        guard (0...markovChain.maximumOrder) ~= order
        else { return nil }

        let ss = markovChain.snapshot

        self.accumulator = ss.accumulator
        self.inContextMap = ss.inContextMap
        self.order = order
        self.outContextMap = ss.outContextMap
        self.simpleMarkovChain = SimpleMarkovChain(accumulator: ss.accumulator,
                                                   rng: rng)
    }

    // MARK: Internal Instance Properties

    internal let order: Int

    // MARK: Private Instance Properties

    private let accumulator: Accumulator
    private let inContextMap: IndexMap<Context<State>>
    private let outContextMap: IndexMap<Context<State>>

    private var simpleMarkovChain: SimpleMarkovChain
}

// MARK: -

extension SimpleGenerator {

    // MARK: Internal Instance Methods

    internal mutating func generate(upTo limit: Int) -> [State] {
        guard limit > 0
        else { return [] }

        return if order > 0 {
            _generateN(upTo: limit)
        } else {
            _generate0(upTo: limit)
        }
    }

    internal mutating func generate(until predicate: (State) -> Bool) -> [State] {
        if order > 0 {
            _generateN(until: predicate)
        } else {
            _generate0(until: predicate)
        }
    }

    internal mutating func next(after states: [State]) -> State? {
        let context = _context(for: states)

        guard let nextContext = _next(after: context),
              case let .single(state) = nextContext
        else { return nil }

        return state
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        let context: Context<State>

        switch source {
        case .begin:
            context = _context(for: [])

        case let .states(states):
            context = _context(for: states)

        case .zero:
            context = .zero
        }

        guard let inIndex = inContextMap[context]
        else { return [] }

        return accumulator.extractElements(for: inIndex).compactMap { element in
            guard let outContext = outContextMap[element.key.outIndex]
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

    private mutating func _generate0(upTo limit: Int) -> [State] {
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

    private mutating func _generateN(upTo limit: Int) -> [State] {
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

// MARK: - MarkovChain.Generator

extension SimpleGenerator: MarkovChain<State>.Generator {
}
