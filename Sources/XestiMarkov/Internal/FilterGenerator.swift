// © 2026 John Gary Pusey (see LICENSE.md)

internal struct FilterGenerator<State> where State: Codable,
                                             State: Comparable,
                                             State: Hashable,
                                             State: Sendable {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Initializers

    internal init(source: any MarkovChain<State>.Generator,
                  predicate: @escaping @Sendable (State) -> Bool,
                  rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
        self.predicate = predicate
        self.rng = rng
        self.source = source
    }

    // MARK: Private Instance Properties

    private let predicate: @Sendable (State) -> Bool

    private var rng: AnyRandomNumberGenerator
    private var source: any MarkovChain<State>.Generator
}

// MARK: -

extension FilterGenerator {

    // MARK: Internal Instance Methods

    internal mutating func next(after states: [State]) -> State? {
        let source: Source = states.isEmpty ? .begin : .states(states)
        let distribution = weights(after: source)

        guard let target = sample(from: distribution,
                                  using: &rng)
        else { return nil }

        if case let .state(s) = target {
            return s
        }

        return nil
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        self.source.weights(after: source).filter { pair in
            if case let .state(s) = pair.target {
                return predicate(s)
            }

            return true  // always retain .end
        }
    }
}

// MARK: - MarkovChain.Generator

extension FilterGenerator: MarkovChain<State>.Generator {
}
