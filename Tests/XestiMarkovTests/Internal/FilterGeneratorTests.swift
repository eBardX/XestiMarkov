// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct FilterGeneratorTests {
}

// MARK: -

extension FilterGeneratorTests {
    @Test
    func generate_limit_appliesPredicate() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c", "a", "b", "c"])

        let mockRNG = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))
        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1,
                                                                                     rng: mockRNG))

        var gen = FilterGenerator(source: source) { $0 != "b" }

        let result = gen.generate(upTo: 20)

        #expect(result.allSatisfy { $0 != "b" })
    }

    @Test
    func generate_limit_stopsAtLimit() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "a", "b", "a", "b"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain, order: 1))

        var gen = FilterGenerator(source: source) { _ in true }

        #expect(gen.generate(upTo: 3).count <= 3)
    }

    @Test
    func next_endNotFiltered() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain, order: 1))

        // Predicate always returns false — but .end is not filtered.
        var gen = FilterGenerator(source: source) { _ in false }

        // "a" can only go to .end; filtering doesn't block that.
        // generate stops naturally (next returns nil on .end).
        let result = gen.generate(upTo: 10)

        #expect(result.isEmpty)
    }

    @Test
    func next_returnsNil_whenAllFiltered() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain, order: 1))

        // Filter out all non-begin states reachable from "a".
        var gen = FilterGenerator(source: source) { $0 != "b" && $0 != "c" }

        // From .begin we get "a". From "a" the only successor "b" is filtered.
        let result = gen.generate(upTo: 10)

        #expect(result == ["a"])
    }

    @Test
    func weights_filtersFailingStates() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b"])
        chain.analyzer().analyze(sequence: ["a", "c"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))
        let gen = FilterGenerator(source: source) { $0 != "c" }

        let weights = gen.weights(after: .states(["a"]))
        let targets = weights.map(\.target)

        #expect(targets.contains(.state("b")))
        #expect(!targets.contains(.state("c")))
    }

    @Test
    func weights_retainsEndTarget() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))
        let gen = FilterGenerator(source: source) { _ in false }

        let weights = gen.weights(after: .states(["a"]))

        #expect(weights.map(\.target).contains(.end))
    }

    @Test
    func weights_returnsEmpty_whenAllFiltered() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))

        // From .begin only "a" is reachable; filter it out.
        let gen = FilterGenerator(source: source) { _ in false }

        // The only .begin successor is .state("a"), which fails the predicate.
        // (.end is not a .begin successor here, so nothing survives.)
        let weights = gen.weights(after: .begin)

        #expect(weights.isEmpty)
    }
}
