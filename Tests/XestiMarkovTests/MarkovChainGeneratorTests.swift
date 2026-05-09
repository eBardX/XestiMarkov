// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov
import XestiTools

struct MarkovChainGeneratorTests {
}

// MARK: -

extension MarkovChainGeneratorTests {
    @Test
    func generate_emptyModel() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var generator = try #require(markovChain.generator())

        #expect(generator.generate(upTo: 10).isEmpty)
    }

    @Test
    func generate_limitZero() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var generator = try #require(markovChain.generator())

        #expect(generator.generate(upTo: 0).isEmpty)
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

        #expect(generator.generate(upTo: 10).count == 3)
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

        #expect(generator.generate(upTo: 10).count == 2)
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

        #expect(generator.generate(upTo: 10).count == 4)
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

        #expect(generator.generate(upTo: 10).count == 3)
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
    func generator_blending_customWeights_closureReceivesContext() throws {
        let chain1 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain1.analyzer().analyze(sequence: ["a", "a", "a"])

        let chain2 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain2.analyzer().analyze(sequence: ["b", "b", "b"])

        let src1 = try #require(chain1.generator(order: 0))
        let src2 = try #require(chain2.generator(order: 0))

        // context empty → 100% src1; context non-empty → 100% src2.
        let gen = MarkovChain<String>.generator(blending: [src1, src2]) { _, context in
            context.isEmpty ? [1.0, 0.0] : [0.0, 1.0]
        }

        let beginTargets = gen.weights(after: .begin).map(\.target)
        let afterATargets = gen.weights(after: .states(["a"])).map(\.target)

        // begin → context=[] → 100% src1 → "a" present, "b" absent.
        #expect(beginTargets.contains(.state("a")))
        #expect(!beginTargets.contains(.state("b")))

        // states(["a"]) → context=["a"] → 100% src2 → "b" present, "a" absent.
        #expect(afterATargets.contains(.state("b")))
        #expect(!afterATargets.contains(.state("a")))
    }

    @Test
    func generator_blending_customWeights_closureReceivesCorrectStep() throws {
        // Verify step indices by using step-dependent weights that alternate
        // between two deterministic single-state chains.
        let chain1 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain1.analyzer().analyze(sequences: [["a"], ["a"], ["a"], ["a"]])

        let chain2 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain2.analyzer().analyze(sequences: [["x"], ["x"], ["x"], ["x"]])

        let src1 = try #require(chain1.generator(order: 0))
        let src2 = try #require(chain2.generator(order: 0))

        // step 0 → "a", step 1 → "x", step 2 → "a", step 3 → "x"
        var gen = MarkovChain<String>.generator(blending: [src1, src2]) { step, _ in
            step.isMultiple(of: 2) ? [1.0, 0.0] : [0.0, 1.0]
        }

        let result = gen.generate(upTo: 4)

        #expect(result == ["a", "x", "a", "x"])
    }

    @Test
    func generator_blending_fixedWeights_producesValues() throws {
        let chain1 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain1.analyzer().analyze(sequence: ["a", "b", "a", "b"])

        let chain2 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain2.analyzer().analyze(sequence: ["x", "y", "x", "y"])

        let src1 = try #require(chain1.generator(order: 1))
        let src2 = try #require(chain2.generator(order: 1))

        var gen = MarkovChain<String>.generator(blending: [(src1, weight: 1.0),
                                                           (src2, weight: 1.0)])

        let result = gen.generate(upTo: 4)

        #expect(!result.isEmpty)
    }

    @Test
    func generator_blending_fixedWeights_singleSource() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(blending: [(source, weight: 1.0)])

        #expect(gen.generate(upTo: 10) == ["a", "b", "c"])
    }

    @Test
    func generator_contrast_high_favoursCommonState() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        // begin → "a" (3×), begin → "b" (1×)
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["b", "x"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(contrasting: source, by: 8.0)

        // Run many steps; "a" should dominate overwhelmingly.
        var counts: [String: Int] = [:]

        for _ in 0..<100 {
            if let state = gen.next(after: []) {
                counts[state, default: 0] += 1
            }
        }

        let aCount = counts["a"] ?? 0
        let bCount = counts["b"] ?? 0

        #expect(aCount > bCount * 5)
    }

    @Test
    func generator_contrast_low_flattensDistribution() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["b", "x"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(contrasting: source, by: 0.1)
        var counts: [String: Int] = [:]

        for _ in 0..<100 {
            if let state = gen.next(after: []) {
                counts[state, default: 0] += 1
            }
        }

        let aCount = counts["a"] ?? 0
        let bCount = counts["b"] ?? 0

        // With extreme flattening, "b" should be seen much more than at 1:3 ratio.
        // At least 20 % of samples should be "b".
        #expect(bCount >= 15)
        #expect(aCount > 0)
    }

    @Test
    func generator_contrast_neutral_matchesSource() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["a", "x"])
        chain.analyzer().analyze(sequence: ["b", "x"])

        let source = try #require(chain.generator(order: 1))
        let gen = MarkovChain<String>.generator(contrasting: source, by: 1.0)
        let weights = gen.weights(after: .begin)
        let aWeight = weights.first { $0.target == .state("a") }?.weight ?? 0
        let bWeight = weights.first { $0.target == .state("b") }?.weight ?? 0

        // contrast 1.0 → identity transform; ratio should remain 3:1.
        #expect(abs(aWeight / bWeight - 3.0) < 1e-9)
    }

    @Test
    func generator_fallback_bothFailReturnsNil() throws {
        let empty1 = try #require(MarkovChain<String>(maximumOrder: 1))
        let empty2 = try #require(MarkovChain<String>(maximumOrder: 1))
        let p = try #require(empty1.generator(order: 1))
        let s = try #require(empty2.generator(order: 1))

        var gen = MarkovChain<String>.generator(trying: p, otherwise: s)

        #expect(gen.next(after: []) == nil)
    }

    @Test
    func generator_fallback_committing_staysInFallback() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary has no .begin entry.

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x", "y", "z"])

        let p = try #require(chainP.generator(order: 1))
        let s = try #require(chainS.generator(order: 1))

        var gen = MarkovChain<String>.generator(trying: p,
                                                otherwise: s,
                                                committing: true)

        // First call misses primary → secondary "x", latched.
        #expect(gen.next(after: []) == "x")

        // Subsequent calls use secondary even though primary has "x"→… context.
        #expect(gen.next(after: ["x"]) == "y")
        #expect(gen.next(after: ["x", "y"]) == "z")
    }

    @Test
    func generator_fallback_primarySucceeds() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        chainP.analyzer().analyze(sequence: ["a", "b", "c"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p = try #require(chainP.generator(order: 1))
        let s = try #require(chainS.generator(order: 1))

        var gen = MarkovChain<String>.generator(trying: p, otherwise: s)

        #expect(gen.next(after: []) == "a")
    }

    @Test
    func generator_fallback_secondaryUsedOnNil() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary has no .begin entry.

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p = try #require(chainP.generator(order: 1))
        let s = try #require(chainS.generator(order: 1))

        var gen = MarkovChain<String>.generator(trying: p, otherwise: s)

        #expect(gen.next(after: []) == "x")
    }

    @Test
    func generator_fallback_terminalFiresFallback() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary: begin → "a" → .end
        chainP.analyzer().analyze(sequence: ["a"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p = try #require(chainP.generator(order: 1))
        let s = try #require(chainS.generator(order: 1))

        var gen = MarkovChain<String>.generator(trying: p, otherwise: s)

        #expect(gen.next(after: []) == "a")
        #expect(gen.next(after: ["a"]) == "x")  // primary terminates; fallback continues
    }

    @Test
    func generator_fallback_transient_resumesPrimary() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary knows: "b" → "c"
        chainP.analyzer().analyze(sequence: ["b", "c"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        // Secondary knows: begin → "b"
        chainS.analyzer().analyze(sequence: ["b", "c"])

        let p = try #require(chainP.generator(order: 1))
        let s = try #require(chainS.generator(order: 1))

        var gen = MarkovChain<String>.generator(trying: p, otherwise: s)

        // Step 1: primary has no .begin → secondary gives "b"
        #expect(gen.next(after: []) == "b")

        // Step 2: history ["b"]; primary knows "b" → "c" → primary takes over
        #expect(gen.next(after: ["b"]) == "c")
    }

    @Test
    func generator_filtering_allFilteredReturnsNil() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(filtering: source) { _ in false }

        // From .begin, only "a" is reachable; predicate rejects it → nil.
        #expect(gen.next(after: []) == nil)
    }

    @Test
    func generator_filtering_endPassesThrough() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(filtering: source) { _ in true }

        // "a" is produced, then chain terminates naturally.
        let result = gen.generate(upTo: 10)

        #expect(result == ["a"])
    }

    @Test
    func generator_filtering_passesMatchingStates() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b", "c", "a", "b", "c"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(filtering: source) { $0 != "b" }

        let result = gen.generate(upTo: 20)

        #expect(result.allSatisfy { $0 != "b" })
    }

    @Test
    func generator_filtering_rejectsFailingStates() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a", "b"])
        chain.analyzer().analyze(sequence: ["a", "c"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(filtering: source) { $0 != "c" }

        let result = gen.generate(upTo: 20)

        #expect(!result.contains("c"))
    }

    @Test
    func generator_interpolating_fullyArrived() throws {
        let chain1 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain1.analyzer().analyze(sequence: ["a"])

        let chain2 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain2.analyzer().analyze(sequence: ["b"])

        let from = try #require(chain1.generator(order: 1))
        let to = try #require(chain2.generator(order: 1))

        // LinearInterpolator: at step == steps the blend weight is 1.0 → 100% "to".
        var gen = MarkovChain<String>.generator(interpolating: from,
                                                to: to,
                                                over: 1,
                                                using: LinearInterpolator())

        // Step 0: t = 0/1 = 0.0 → w = 0.0 → 100% from → "a"
        let step0 = gen.next(after: [])

        // Step 1: t = 1/1 = 1.0 → w = 1.0 → 100% to → "b"
        let step1 = gen.next(after: [])

        #expect(step0 == "a")
        #expect(step1 == "b")
    }

    @Test
    func generator_interpolating_fullyFrom() throws {
        let chain1 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain1.analyzer().analyze(sequence: ["a", "b", "c"])

        let chain2 = try #require(MarkovChain<String>(maximumOrder: 1))

        chain2.analyzer().analyze(sequence: ["x", "y", "z"])

        let from = try #require(chain1.generator(order: 1))
        let to = try #require(chain2.generator(order: 1))

        // ConstantInterpolator(value: 0) always returns 0 → 100% from throughout.
        var gen = MarkovChain<String>.generator(interpolating: from,
                                                to: to,
                                                over: 100,
                                                using: ConstantInterpolator())

        let result = gen.generate(upTo: 10)

        #expect(result == ["a", "b", "c"])
    }

    @Test
    func generator_looping_continuesPastTerminal() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        // Deterministic: begin → "a" → .end
        chain.analyzer().analyze(sequence: ["a"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(looping: source)

        let result = gen.generate(upTo: 5)

        // Should restart 5 times producing ["a", "a", "a", "a", "a"].
        #expect(result.count == 5)
        #expect(result.allSatisfy { $0 == "a" })
    }

    @Test
    func generator_looping_emptyModel_returnsEmpty() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(looping: source)

        #expect(gen.generate(upTo: 10).isEmpty)
    }

    @Test
    func generator_looping_respectsLimit() throws {
        let chain = try #require(MarkovChain<String>(maximumOrder: 1))

        chain.analyzer().analyze(sequence: ["a"])

        let source = try #require(chain.generator(order: 1))

        var gen = MarkovChain<String>.generator(looping: source)

        let result = gen.generate(upTo: 3)

        #expect(result.count <= 3)
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
}
