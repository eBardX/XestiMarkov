// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainProbabilityTests {
}

// MARK: -

extension MarkovChainProbabilityTests {
    @Test
    func probability_deterministic_begin() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.probability(of: .state("a"), after: .begin) == 1.0)
    }

    @Test
    func probability_deterministic_end() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.probability(of: .end, after: .states(["b"])) == 1.0)
    }

    @Test
    func probability_emptyChain() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.probability(of: .state("a"), after: .zero) == nil)
    }

    @Test
    func probability_emptyStatesSource() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.probability(of: .state("a"), after: .states([])) == nil)
    }

    @Test
    func probability_fractional() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.probability(of: .state("b"), after: .states(["a"])) == 0.5)
        #expect(markovChain.probability(of: .state("c"), after: .states(["a"])) == 0.5)
    }

    @Test
    func probability_order2() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c", "a", "b", "d"])

        #expect(markovChain.probability(of: .state("c"), after: .states(["a", "b"])) == 0.5)
        #expect(markovChain.probability(of: .state("d"), after: .states(["a", "b"])) == 0.5)
    }

    @Test
    func probability_sumToOne() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let source = MarkovChain<String>.Transition.Source.states(["a"])
        var sum = 0.0

        markovChain.forEach { transition in
            guard transition.source == source
            else { return }

            guard let p = markovChain.probability(of: transition.target,
                                                  after: source)
            else { return }

            sum += p
        }

        #expect(abs(sum - 1.0) < 1e-9)
    }

    @Test
    func probability_unknownSource() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.probability(of: .state("a"), after: .states(["x"])) == nil)
    }

    @Test
    func probability_unknownTarget() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.probability(of: .state("z"), after: .states(["a"])) == 0.0)
    }

    @Test
    func probability_zeroOrder() throws {
        let expectedA = 2.0 / 3.0
        let expectedB = 1.0 / 3.0

        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "a", "b"])

        let pA = try #require(markovChain.probability(of: .state("a"), after: .zero))
        let pB = try #require(markovChain.probability(of: .state("b"), after: .zero))

        #expect(abs(pA - expectedA) < 1e-9)
        #expect(abs(pB - expectedB) < 1e-9)
    }
}
