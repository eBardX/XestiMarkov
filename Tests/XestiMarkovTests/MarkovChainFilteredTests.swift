// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
import XestiMarkov

struct MarkovChainFilteredTests {
}

// MARK: -

extension MarkovChainFilteredTests {
    @Test
    func filtered_all_generatesIdentically() throws {
        let markovChain = try #require(MarkovChain<Int>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequences: [[1, 2, 3, 1, 3, 2], [2, 1, 1, 3, 2, 2, 3]])

        let filtered = markovChain.filtered { _ in true }

        for seed in UInt64(0)..<10 {
            var gen1 = try #require(markovChain.generator(order: 2,
                                                          using: SeededRandomNumberGenerator(seed: seed)))
            var gen2 = try #require(filtered.generator(order: 2,
                                                       using: SeededRandomNumberGenerator(seed: seed)))

            #expect(gen1.generate(upTo: 50) == gen2.generate(upTo: 50))
        }
    }

    @Test
    func filtered_all_keepsEveryTransition() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequences: [["a", "b", "c"], ["b", "a", "c", "a"]])

        let filtered = markovChain.filtered { _ in true }

        #expect(filtered.maximumOrder == markovChain.maximumOrder)
        #expect(allTransitions(of: filtered) == allTransitions(of: markovChain))
    }

    @Test
    func filtered_byWeight_prunesRareTransitions() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequences: [["a", "b"], ["a", "b"], ["a", "c"]])

        let pruned = markovChain.filtered { $0.weight > 1 }

        #expect(pruned.probability(of: .state("b"), after: .states(["a"])) == 1.0)
        #expect(pruned.probability(of: .state("c"), after: .states(["a"])) == 0.0)
        #expect(!pruned.states.contains("c"))
    }

    @Test
    func filtered_empty() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        let filtered = markovChain.filtered { _ in false }

        #expect(filtered.isEmpty)
        #expect(!markovChain.isEmpty)
    }

    @Test
    func filtered_keepsAnchoring() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequences: [["a", "b"], ["c", "a", "c"]])

        let filtered = markovChain.filtered { _ in true }

        #expect(filtered.probability(of: .state("b"), after: .beginStates(["a"])) == 1.0)
        #expect(filtered.probability(of: .state("b"), after: .states(["a"])) == 0.5)
    }

    @Test
    func filtered_removingState() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequence: ["a", "x", "b", "a", "b"])

        let filtered = markovChain.filtered { !transitionMentions($0, "x") }

        #expect(!filtered.states.contains("x"))
        #expect(markovChain.states.contains("x"))

        filtered.forEach { #expect(!transitionMentions($0, "x")) }
    }

    @Test
    func filtered_throws() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a"])

        #expect(throws: TestError.self) {
            _ = try markovChain.filtered { _ in throw TestError() }
        }
    }
}
