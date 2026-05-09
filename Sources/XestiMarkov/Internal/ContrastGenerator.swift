// © 2026 John Gary Pusey (see LICENSE.md)

private import Foundation

internal struct ContrastGenerator<State> where State: Codable,
                                               State: Comparable,
                                               State: Hashable,
                                               State: Sendable {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Initializers

    internal init(source: any MarkovChain<State>.Generator,
                  contrast: Double,
                  rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
        self.contrast = contrast
        self.rng = rng
        self.source = source
    }

    // MARK: Private Instance Properties

    private let contrast: Double

    private var rng: AnyRandomNumberGenerator
    private var source: any MarkovChain<State>.Generator
}

// MARK: -

extension ContrastGenerator {

    // MARK: Internal Instance Methods

    internal mutating func next(after states: [State]) -> State? {
        let src: Source = states.isEmpty ? .begin : .states(states)
        let distribution = weights(after: src)

        guard let target = sample(from: distribution,
                                  using: &rng)
        else { return nil }

        if case let .state(s) = target {
            return s
        }

        return nil
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        let rawWeights = self.source.weights(after: source)

        guard !rawWeights.isEmpty
        else { return [] }

        let total = rawWeights.reduce(0.0) { $0 + $1.weight }

        guard total > 0
        else { return [] }

        let exponent = contrast

        return rawWeights.map { (target: $0.target,
                                 weight: pow($0.weight / total,
                                             exponent))
        }
    }
}

// MARK: - MarkovChain.Generator

extension ContrastGenerator: MarkovChain<State>.Generator {
}
