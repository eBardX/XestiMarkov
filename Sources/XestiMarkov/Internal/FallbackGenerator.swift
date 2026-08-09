// © 2026 John Gary Pusey (see LICENSE.md)

internal struct FallbackGenerator<State> where State: Codable,
                                               State: Comparable,
                                               State: Hashable,
                                               State: Sendable {

    // MARK: Internal Initializers

    internal init(primary: any MarkovChain<State>.Generator,
                  secondary: any MarkovChain<State>.Generator,
                  committing: Bool) {
        self.committing = committing
        self.committed = false
        self.primary = primary
        self.secondary = secondary
    }

    // MARK: Private Instance Properties

    private let committing: Bool

    private var committed: Bool
    private var primary: any MarkovChain<State>.Generator
    private var secondary: any MarkovChain<State>.Generator
}

// MARK: -

extension FallbackGenerator {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Instance Methods

    internal mutating func next(after states: [State]) -> State? {
        if committed {
            return secondary.next(after: states)
        }

        if let state = primary.next(after: states) {
            return state
        }

        if committing {
            committed = true
        }

        return secondary.next(after: [])
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        if committed {
            return secondary.weights(after: source)
        }

        let primaryWeights = primary.weights(after: source)

        if !primaryWeights.isEmpty {
            return primaryWeights
        }

        return secondary.weights(after: source)
    }
}

// MARK: - MarkovChain.Generator

extension FallbackGenerator: MarkovChain<State>.Generator {
}
