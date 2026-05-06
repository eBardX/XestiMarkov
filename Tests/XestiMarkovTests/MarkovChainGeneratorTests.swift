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

    // The following four tests expose the bug in _generateN where `limit` is
    // passed instead of `order` to prevState.append. Each corpus is chosen so
    // that every transition is deterministic (weight 1 on exactly one outgoing
    // edge), which makes the expected count predictable without a mock RNG.

    @Test
    func generate_order1_threeStateChain() throws {
        // Corpus: ["a", "b", "c"]
        //   .begin → "a" (only)
        //   "a"    → "b" (only)
        //   "b"    → "c" (only)
        //   "c"    → .end (only)
        // Expected count: 3. The bug stops generation after 1 state.
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(limit: 10).count == 3)
    }

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

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(limit: 10).count == 2)
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

        markovChain.analyzer().analyze(sequence: ["a", "b", "c", "d"])

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

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 2))

        #expect(generator.generate(limit: 10).count == 3)
    }

    @Test
    func generate_until_emptyModel() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let predicate: (String) -> Bool = { _ in true }

        var generator = try #require(markovChain.generator())

        #expect(generator.generate(until: predicate).isEmpty)
    }

    @Test
    func generate_until_firstState() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let predicate: (String) -> Bool = { $0 == "a" }

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(until: predicate) == ["a"])
    }

    @Test
    func generate_until_intermediateState() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let predicate: (String) -> Bool = { $0 == "b" }

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(until: predicate) == ["a", "b"])
    }

    @Test
    func generate_until_neverFires() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let predicate: (String) -> Bool = { _ in false }

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.generate(until: predicate) == ["a", "b", "c"])
    }

    @Test
    func generate_until_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let predicate: (String) -> Bool = { $0 == "a" }

        markovChain.analyzer().analyze(sequence: ["a"])

        var generator = try #require(markovChain.generator(order: 0))

        #expect(generator.generate(until: predicate) == ["a"])
    }

    @Test
    func init_failure() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.generator(order: -1) == nil)
        #expect(markovChain.generator(order: 2) == nil)
    }

    @Test
    func next_after_emptyStates() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.next() == "a")
    }

    @Test
    func next_after_knownContext() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.next(after: ["a"]) == "b")
        #expect(generator.next(after: ["b"]) == "c")
    }

    @Test
    func next_after_longerThanOrder() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        // Only the last element matters for order 1; "a" is ignored
        #expect(generator.next(after: ["a", "b"]) == "c")
    }

    @Test
    func next_after_terminalContext() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.next(after: ["c"]) == nil)
    }

    @Test
    func next_after_unknownContext() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        var generator = try #require(markovChain.generator(order: 1))

        #expect(generator.next(after: ["z"]) == nil)
    }

    @Test
    func next_emptyModel() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var generator = try #require(markovChain.generator())

        #expect(generator.next() == nil)
    }

    @Test
    func next_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a"])

        var generator = try #require(markovChain.generator(order: 0))

        // Order 0 ignores states; result depends only on frequency
        #expect(generator.next(after: ["z"]) == "a")
    }

    @Test
    func order() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 3))

        #expect(markovChain.generator(order: 0)?.order == 0)
        #expect(markovChain.generator(order: 1)?.order == 1)
        #expect(markovChain.generator(order: 2)?.order == 2)
        #expect(markovChain.generator(order: 3)?.order == 3)
    }
}
