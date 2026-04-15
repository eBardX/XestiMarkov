// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovGeneratorTests {
}

// MARK: -

extension MarkovGeneratorTests {
    @Test
    func generate_emptyModel() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))

        var generator = try #require(markov.generator())

        #expect(generator.generate(limit: 10).isEmpty)
    }

    @Test
    func generate_limitZero() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))

        var generator = try #require(markov.generator())

        #expect(generator.generate(limit: 0).isEmpty)
    }

    @Test
    func init_failure() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))

        #expect(markov.generator(order: -1) == nil)
        #expect(markov.generator(order: 2) == nil)
    }

    @Test
    func order() throws {
        let markov = try #require(Markov<String>(maximumOrder: 3))

        #expect(markov.generator(order: 0)?.order == 0)
        #expect(markov.generator(order: 1)?.order == 1)
        #expect(markov.generator(order: 2)?.order == 2)
        #expect(markov.generator(order: 3)?.order == 3)
    }

    // The following three tests expose the bug in _generateN where `limit` is
    // passed instead of `order` to prevState.append. Each corpus is chosen so
    // that every transition is deterministic (weight 1 on exactly one outgoing
    // edge), which makes the expected count predictable without a mock RNG.

    @Test
    func generate_order1_twoEventChain() throws {
        // Corpus: ["a", "b"]
        //   .begin → "a" (only)
        //   "a"    → "b" (only)
        //   "b"    → .end (only)
        // With a correct context window of order=1 the generator should produce
        // ["a", "b"] (count 2). The bug causes it to stop after the first event
        // because after appending "a" to ``.begin` the context grows to a
        // 2-element sequence that is absent from the order-1 map.
        let markov = try #require(Markov<String>(maximumOrder: 1))

        markov.analyzer().analyze(["a", "b"])

        var generator = try #require(markov.generator(order: 1))

        #expect(generator.generate(limit: 10).count == 2)
    }

    @Test
    func generate_order1_threeEventChain() throws {
        // Corpus: ["a", "b", "c"]
        //   .begin → "a" (only)
        //   "a"    → "b" (only)
        //   "b"    → "c" (only)
        //   "c"    → .end (only)
        // Expected count: 3. The bug stops generation after 1 event.
        let markov = try #require(Markov<String>(maximumOrder: 1))

        markov.analyzer().analyze(["a", "b", "c"])

        var generator = try #require(markov.generator(order: 1))

        #expect(generator.generate(limit: 10).count == 3)
    }

    @Test
    func generate_order2_fourEventChain() throws {
        // Corpus: ["a", "b", "c", "d"] with maximumOrder=2.
        // The order-2 map contains:
        //   [.begin, "a"] → "b"
        //   ["a", "b"]    → "c"
        //   ["b", "c"]    → "d"
        //   ["c", "d"]    → .end
        // Expected count: 4.
        let markov = try #require(Markov<String>(maximumOrder: 2))

        markov.analyzer().analyze(["a", "b", "c", "d"])

        var generator = try #require(markov.generator(order: 2))

        #expect(generator.generate(limit: 10).count == 4)
    }

    @Test
    func generate_order2_threeEventChain() throws {
        // Corpus: ["a", "b", "c"] with maximumOrder=2.
        // The order-2 map contains:
        //   [.begin, "a"] → "b"
        //   ["a", "b"]    → "c"
        //   ["b", "c"]    → .end
        // Expected count: 3. The bug stops generation after 2 events because
        // the context grows to a 3-element sequence that is absent from the
        // map.
        let markov = try #require(Markov<String>(maximumOrder: 2))

        markov.analyzer().analyze(["a", "b", "c"])

        var generator = try #require(markov.generator(order: 2))

        #expect(generator.generate(limit: 10).count == 3)
    }
}
