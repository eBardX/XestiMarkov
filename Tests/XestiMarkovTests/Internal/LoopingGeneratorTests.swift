// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct LoopingGeneratorTests {
}

// MARK: -

extension LoopingGeneratorTests {
    @Test
    func generate_limit_loopsOnTerminal() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        // Short deterministic chain: begin → "a" → .end
        chain.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))

        var gen = LoopingGenerator(source: source)

        let result = gen.generate(upTo: 5)

        // Should restart and accumulate 5 copies of "a".
        #expect(result.count == 5)
        #expect(result.allSatisfy { $0 == "a" })
    }

    @Test
    func generate_limit_respectsLimit() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))

        var gen = LoopingGenerator(source: source)

        let result = gen.generate(upTo: 3)

        #expect(result.count <= 3)
    }

    @Test
    func generate_until_loopsOnTerminal() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        // begin → "a" → "b" → .end; predicate fires on "b"
        chain.analyzer().analyze(sequence: ["a", "b"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))

        var gen = LoopingGenerator(source: source)

        // Predicate fires on the second "b" so the generator restarts once.
        var hitCount = 0

        let result = gen.generate { s in
            if s == "b" {
                hitCount += 1
                return hitCount >= 2
            }
            return false
        }

        #expect(result.count >= 4)  // at least a, b, a, b
        #expect(result.last == "b")
    }

    @Test
    func next_loopsOnNil() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))

        var gen = LoopingGenerator(source: source)

        // After "a" the source would return nil; looping retries from .begin.
        let result = gen.next(after: ["a"])

        #expect(result == "a")
    }

    @Test
    func next_returnsNil_whenSourceAlwaysNil() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        // Untrained chain — every context returns nil.
        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))

        var gen = LoopingGenerator(source: source)

        #expect(gen.next(after: []) == nil)
    }

    @Test
    func weights_removesEndTargets() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chain,
                                                                                     order: 1))
        let gen = LoopingGenerator(source: source)

        // "a" only transitions to .end; looping generator strips that.
        let weights = gen.weights(after: .states(["a"]))

        #expect(weights.isEmpty)
        #expect(!weights.map(\.target).contains(.end))
    }
}
