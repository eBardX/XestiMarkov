// © 2026 John Gary Pusey (see LICENSE.md)

internal func sample<State: Comparable>(from distribution: [(target: MarkovChain<State>.Transition.Target,
                                                             weight: Double)],
                                        using rng: inout AnyRandomNumberGenerator) -> MarkovChain<State>.Transition.Target? {
    guard !distribution.isEmpty
    else { return nil }

    let totalWeight = distribution.reduce(0.0) { $0 + $1.weight }

    guard totalWeight > 0
    else { return nil }

    let roll = Double.random(in: 0..<totalWeight,
                             using: &rng)

    let sorted = distribution.sorted {
        switch ($0.target, $1.target) {
        case (.end, .end),
            (.state, .end):
            return false

        case (.end, .state):
            return true

        case let (.state(lstate), .state(rstate)):
            return lstate < rstate
        }
    }

    var runningWeight = 0.0

    for (target, weight) in sorted {
        runningWeight += weight

        if runningWeight > roll {
            return target
        }
    }

    return nil
}
