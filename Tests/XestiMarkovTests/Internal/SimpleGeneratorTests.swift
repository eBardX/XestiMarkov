// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct SimpleGeneratorTests {
}

// MARK: -

extension SimpleGeneratorTests {
    @Test
    func init_failure() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(SimpleGenerator<String>(markovChain: chain, order: -1) == nil)
        #expect(SimpleGenerator<String>(markovChain: chain, order: 2) == nil)
    }

    @Test
    func order() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 3))

        #expect(SimpleGenerator<String>(markovChain: chain, order: 0)?.order == 0)
        #expect(SimpleGenerator<String>(markovChain: chain, order: 1)?.order == 1)
        #expect(SimpleGenerator<String>(markovChain: chain, order: 2)?.order == 2)
        #expect(SimpleGenerator<String>(markovChain: chain, order: 3)?.order == 3)
    }

    @Test
    func weights_begin_order0() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "a", "b"])

        let gen = try #require(SimpleGenerator(markovChain: chain, order: 0))
        let weights = gen.weights(after: .begin)

        #expect(!weights.isEmpty)

        let targets = Set(weights.map(\.target))

        #expect(targets.contains(.state("a")))
        #expect(targets.contains(.state("b")))

        let aWeight = weights.first { $0.target == .state("a") }?.weight ?? 0
        let bWeight = weights.first { $0.target == .state("b") }?.weight ?? 0

        #expect(aWeight > bWeight)
    }

    @Test
    func weights_begin_order1() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let gen = try #require(SimpleGenerator(markovChain: chain, order: 1))
        let weights = gen.weights(after: .begin)

        #expect(weights.count == 1)
        #expect(weights[0].target == .state("a"))
    }

    @Test
    func weights_states_order1() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let gen = try #require(SimpleGenerator(markovChain: chain, order: 1))
        let weights = gen.weights(after: .states(["a"]))

        #expect(weights.count == 1)
        #expect(weights[0].target == .state("b"))
    }

    @Test
    func weights_states_tooLong() throws {
        // Order-1 uses only the last element of a longer states array.
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let gen = try #require(SimpleGenerator(markovChain: chain, order: 1))
        let weights = gen.weights(after: .states(["a", "b", "c"]))

        // Truncated to ["c"]; "c" only transitions to .end.
        #expect(weights.count == 1)
        #expect(weights[0].target == .end)
    }

    @Test
    func weights_terminal_context() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let gen = try #require(SimpleGenerator(markovChain: chain, order: 1))
        let weights = gen.weights(after: .states(["c"]))

        #expect(weights.count == 1)
        #expect(weights[0].target == .end)
    }

    @Test
    func weights_unknown_context() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let gen = try #require(SimpleGenerator(markovChain: chain, order: 1))
        let weights = gen.weights(after: .states(["z"]))

        #expect(weights.isEmpty)
    }
}
