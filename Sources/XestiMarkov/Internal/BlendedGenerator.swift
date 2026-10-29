// © 2026 John Gary Pusey (see LICENSE.md)

internal struct BlendedGenerator<State> where State: Codable,
                                              State: Comparable,
                                              State: Hashable,
                                              State: Sendable {

    // MARK: Internal Initializers

    internal init?(sources: [any MarkovChain<State>.Generator],
                   blendWeights: @escaping @Sendable (_ step: Int, _ context: [State]) -> [Double],
                   rng: AnyRandomNumberGenerator = AnyRandomNumberGenerator(SystemRandomNumberGenerator())) {
        guard !sources.isEmpty
        else { return nil }

        self.blendWeights = blendWeights
        self.rng = rng
        self.sources = sources
        self.step = 0
    }

    // MARK: Private Instance Properties

    private let blendWeights: @Sendable (_ step: Int, _ context: [State]) -> [Double]

    private var rng: AnyRandomNumberGenerator
    private var sources: [any MarkovChain<State>.Generator]
    private var step: Int
}

// MARK: -

extension BlendedGenerator {

    // MARK: Internal Type Aliases

    internal typealias Source = MarkovChain<State>.Transition.Source
    internal typealias Target = MarkovChain<State>.Transition.Target
    internal typealias WeightedTarget = (target: Target, weight: Double)

    // MARK: Internal Instance Methods

    internal mutating func next(after states: [State]) -> State? {
        let source: Source = states.isEmpty ? .begin : .states(states)
        let distribution = weights(after: source)
        let target = sample(from: distribution,
                            using: &rng)

        step += 1

        guard case let .state(s) = target
        else { return nil }

        return s
    }

    internal func weights(after source: Source) -> [WeightedTarget] {
        let context: [State] = switch source {
        case .begin,
             .zero:
            []

        case let .beginStates(states),
             let .states(states):
            states
        }

        var rawWeights = blendWeights(step, context)

        guard rawWeights.count == sources.count
        else { return [] }

        var distributions: [[WeightedTarget]] = []

        for i in sources.indices {
            //
            // Normalize each source’s distribution to sum to 1, so that its
            // influence is its blend weight alone, whatever the scale of the
            // weights it returns (raw counts, probabilities, …):
            //
            let dist = sources[i].weights(after: source)
            let total = dist.reduce(0.0) { $0 + $1.weight }

            if total > 0 {
                distributions.append(dist.map { (target: $0.target,
                                                 weight: $0.weight / total)
                })
            } else {
                distributions.append([])
            }

            if distributions[i].isEmpty || !rawWeights[i].isFinite || rawWeights[i] < 0 {
                rawWeights[i] = 0.0
            }
        }

        let totalRaw = rawWeights.reduce(0.0, +)

        guard totalRaw > 0
        else { return [] }

        var combined: [Target: Double] = [:]

        for i in sources.indices {
            guard !distributions[i].isEmpty
            else { continue }

            let w = rawWeights[i] / totalRaw

            guard w > 0
            else { continue }

            for (target, weight) in distributions[i] {
                combined[target, default: 0.0] += weight * w
            }
        }

        return sortByTarget(combined.map { (target: $0.key,
                                            weight: $0.value)
        })
    }
}

// MARK: - MarkovChain.Generator

extension BlendedGenerator: MarkovChain<State>.Generator {
}
