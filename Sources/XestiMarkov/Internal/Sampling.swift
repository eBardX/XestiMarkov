// © 2026 John Gary Pusey (see LICENSE.md)

// MARK: Internal Functions

internal func sample<State: Comparable>(from distribution: [(target: MarkovChain<State>.Transition.Target,
                                                             weight: Double)],
                                        using rng: inout AnyRandomNumberGenerator) -> MarkovChain<State>.Transition.Target? {
    guard !distribution.isEmpty
    else { return nil }

    let sorted = sortByTarget(distribution)
    let totalWeight = sorted.reduce(0.0) { $0 + $1.weight }

    guard totalWeight > 0
    else { return nil }

    let roll = Double.random(in: 0..<totalWeight,
                             using: &rng)

    var runningWeight = 0.0

    for (target, weight) in sorted {
        runningWeight += weight

        if runningWeight > roll {
            return target
        }
    }

    return nil
}

//
// Sorts a distribution by target (`.end` first, then states in ascending
// order), so that sums over it, and samples from it, don’t depend on
// dictionary order.
//
internal func sortByTarget<State: Comparable>(_ distribution: [(target: MarkovChain<State>.Transition.Target,
                                                                weight: Double)]) -> [(target: MarkovChain<State>.Transition.Target,
                                                                                       weight: Double)] {
    distribution.sorted {
        switch ($0.target, $1.target) {
        case (.end, .end),
             (.state, .end):
            false

        case (.end, .state):
            true

        case let (.state(lstate), .state(rstate)):
            lstate < rstate
        }
    }
}
