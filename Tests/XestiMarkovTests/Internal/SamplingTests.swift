// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct SamplingTests {
}

// MARK: -

extension SamplingTests {
    @Test
    func sample_emptyDistribution() {
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = []
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == nil)
    }

    @Test
    func sample_endSortedFirst() {
        // .end sorts before .state; seed 0 → roll ≈ 0 → .end selected despite being listed second.
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .state(1), weight: 0.5),
                                                (target: .end, weight: 0.5)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == .end)
    }

    @Test
    func sample_rollSelectsHigherState() {
        // seed UInt64.max → roll ≈ totalWeight - ε → last (highest) state selected.
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: UInt64.max))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .state(1), weight: 0.5),
                                                (target: .state(2), weight: 0.5)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == .state(2))
    }

    @Test
    func sample_rollSelectsState() {
        // seed UInt64.max → roll ≈ totalWeight - ε → roll past .end bucket selects .state.
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: UInt64.max))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .end, weight: 0.5),
                                                (target: .state(1), weight: 0.5)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == .state(1))
    }

    @Test
    func sample_singleEnd() {
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .end, weight: 1.0)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == .end)
    }

    @Test
    func sample_singleState() {
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .state(42), weight: 1.0)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == .state(42))
    }

    @Test
    func sample_statesAscendingOrder() {
        // States sort ascending; seed 0 → roll ≈ 0 → smallest state selected despite being listed second.
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))

        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .state(2), weight: 0.5),
                                                (target: .state(1), weight: 0.5)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == .state(1))
    }

    @Test
    func sample_zeroWeights() {
        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))
        let distribution: [(target: MarkovChain<Int>.Transition.Target,
                            weight: Double)] = [(target: .state(1), weight: 0.0),
                                                (target: .state(2), weight: 0.0)]
        let result = sample(from: distribution,
                            using: &rng)

        #expect(result == nil)
    }
}
