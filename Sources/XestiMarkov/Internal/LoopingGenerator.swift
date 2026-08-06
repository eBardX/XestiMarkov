// © 2026 John Gary Pusey (see LICENSE.md)

internal struct LoopingGenerator<State> where State: Codable,
                                              State: Comparable,
                                              State: Hashable,
                                              State: Sendable {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Initializers

    internal init(source: any MarkovChain<State>.Generator) {
        self.source = source
    }

    // MARK: Private Instance Properties

    private var source: any MarkovChain<State>.Generator
}

// MARK: -

extension LoopingGenerator {

    // MARK: Internal Instance Methods

    internal mutating func generate(until predicate: (State) -> Bool) -> [State] {
        var result: [State] = []
        var history: [State] = []

        while true {
            let state: State

            if let nextState = source.next(after: history) {
                state = nextState
            } else {
                history = []

                guard let nextState = source.next(after: [])
                else { break }

                state = nextState
            }

            result.append(state)

            if predicate(state) {
                break
            }

            history.append(state)
        }

        return result
    }

    internal mutating func generate(upTo limit: Int) -> [State] {
        guard limit > 0
        else { return [] }

        var result: [State] = []
        var history: [State] = []

        while result.count < limit {
            if let state = source.next(after: history) {
                result.append(state)
                history.append(state)
            } else {
                history = []

                guard let state = source.next(after: [])
                else { break }

                result.append(state)
                history.append(state)
            }
        }

        return result
    }

    internal mutating func next(after states: [State]) -> State? {
        if let state = source.next(after: states) {
            return state
        }

        return source.next(after: [])
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        self.source.weights(after: source).filter { $0.target != .end }
    }
}

// MARK: - MarkovChain.Generator

extension LoopingGenerator: MarkovChain<State>.Generator {
}
