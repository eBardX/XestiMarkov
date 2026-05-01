// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainGeneratorTests {
}

// MARK: -

extension MarkovChainGeneratorTests {
    @Test
    func generate_emptyModel() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var generator = try #require(markovChain.generator())

        #expect(generator.generate(limit: 10).isEmpty)
    }

    @Test
    func generate_limitZero() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var generator = try #require(markovChain.generator())

        #expect(generator.generate(limit: 0).isEmpty)
    }

    @Test
    func init_failure() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.generator(order: -1) == nil)
        #expect(markovChain.generator(order: 2) == nil)
    }

    @Test
    func order() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 3))

        #expect(markovChain.generator(order: 0)?.order == 0)
        #expect(markovChain.generator(order: 1)?.order == 1)
        #expect(markovChain.generator(order: 2)?.order == 2)
        #expect(markovChain.generator(order: 3)?.order == 3)
    }

    // The following three tests expose the bug in _generateN where `limit` is
    // passed instead of `order` to prevState.append. Each corpus is chosen so
    // that every transition is deterministic (weight 1 on exactly one outgoing
    // edge), which makes the expected count predictable without a mock RNG.

    @Test
    func generate_order1_twoStateChain() throws {
        // Corpus: ["a", "b"]
        //   .begin → "a" (only)
        //   "a"    → "b" (only)
        //   "b"    → .end (only)
        // With a correct context window of order=1 the generator should produce
        // ["a", "b"] (count 2). The bug causes it to stop after the first state
        // because after appending "a" to `.begin` the context grows to a
        // 2-element sequence that is absent from the order-1 map.
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(["a", "b"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(limit: 10).count == 2)
    }

    @Test
    func generate_order1_threeStateChain() throws {
        // Corpus: ["a", "b", "c"]
        //   .begin → "a" (only)
        //   "a"    → "b" (only)
        //   "b"    → "c" (only)
        //   "c"    → .end (only)
        // Expected count: 3. The bug stops generation after 1 state.
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(limit: 10).count == 3)
    }

    @Test
    func generate_order2_fourStateChain() throws {
        // Corpus: ["a", "b", "c", "d"] with maximumOrder=2.
        // The order-2 map contains:
        //   [.begin, "a"] → "b"
        //   ["a", "b"]    → "c"
        //   ["b", "c"]    → "d"
        //   ["c", "d"]    → .end
        // Expected count: 4.
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(["a", "b", "c", "d"])

        var generator = try #require(markovChain.generator(order: 2))

        #expect(generator.generate(limit: 10).count == 4)
    }

    @Test
    func generate_order2_threeStateChain() throws {
        // Corpus: ["a", "b", "c"] with maximumOrder=2.
        // The order-2 map contains:
        //   [.begin, "a"] → "b"
        //   ["a", "b"]    → "c"
        //   ["b", "c"]    → .end
        // Expected count: 3. The bug stops generation after 2 states because
        // the context grows to a 3-element sequence that is absent from the
        // map.
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 2))

        #expect(generator.generate(limit: 10).count == 3)
    }
}
