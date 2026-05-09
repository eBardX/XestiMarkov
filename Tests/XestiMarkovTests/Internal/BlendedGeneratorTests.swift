// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct BlendedGeneratorTests {
}

// MARK: -

extension BlendedGeneratorTests {
    @Test
    func generate_limit_stopsAtLimit() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "b"])
        mc.analyzer().analyze(sequence: ["a", "b"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0] }

        var gen = try #require(BlendedGenerator(sources: [source], blendWeights: blend))

        let result = gen.generate(upTo: 1)

        #expect(result.count == 1)
    }

    @Test
    func generate_limit_stopsAtTerminal() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "b"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0] }

        var gen = try #require(BlendedGenerator(sources: [source], blendWeights: blend))

        let result = gen.generate(upTo: 100)

        #expect(result == ["a", "b"])
    }

    @Test
    func generate_until_stopsAtPredicate() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "b", "c"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0] }

        var gen = try #require(BlendedGenerator(sources: [source], blendWeights: blend))

        let result = gen.generate { $0 == "b" }

        #expect(result == ["a", "b"])
    }

    @Test
    func init_failure() {
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [] }
        let result = BlendedGenerator<String>(sources: [], blendWeights: blend)

        #expect(result == nil)
    }

    @Test
    func next_blendedWeights_biasedTowardsHeavierSource() throws {
        let mc1 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc1.analyzer().analyze(sequence: ["a"])

        let mc2 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc2.analyzer().analyze(sequence: ["b"])

        let src1: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc1,
                                                                                   order: 1))
        let src2: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc2,
                                                                                   order: 1))

        // Seed 0 → roll ≈ 0.0; with 90 % weight on "a" this always picks "a".
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [0.9, 0.1] }

        var gen = try #require(BlendedGenerator(sources: [src1, src2],
                                                blendWeights: blend,
                                                rng: AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))))

        #expect(gen.next(after: []) == "a")
    }

    @Test
    func next_emptyHistoryUsesBegin() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "b", "c"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0] }

        var gen = try #require(BlendedGenerator(sources: [source], blendWeights: blend))

        // .begin context has exactly one successor: "a".
        #expect(gen.next(after: []) == "a")
    }

    @Test
    func next_missingContext_redistributes() throws {
        // mc1 is empty (no distribution for .begin).
        let mc1 = try #require(MarkovChain<String>(maximumOrder: 1))
        let mc2 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc2.analyzer().analyze(sequence: ["b"])

        let src1: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc1,
                                                                                   order: 1))
        let src2: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc2,
                                                                                   order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [0.5, 0.5] }

        var gen = try #require(BlendedGenerator(sources: [src1, src2], blendWeights: blend))

        // All weight redistributes to source2 → must produce "b".
        #expect(gen.next(after: []) == "b")
    }

    @Test
    func next_returnsNilForTerminalState() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0] }

        var gen = try #require(BlendedGenerator(sources: [source], blendWeights: blend))

        // "a" → .end; next after "a" is nil.
        #expect(gen.next(after: ["a"]) == nil)
    }

    @Test
    func weights_allSourcesMissing_returnsEmpty() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        // Empty chain has no distribution for any context.
        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0] }
        let gen = try #require(BlendedGenerator(sources: [source], blendWeights: blend))

        #expect(gen.weights(after: .begin).isEmpty)
    }

    @Test
    func weights_contextAware_variesByContext() throws {
        let mc1 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc1.analyzer().analyze(sequence: ["a", "a", "a"])

        let mc2 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc2.analyzer().analyze(sequence: ["b", "b", "b"])

        let src1: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc1,
                                                                                   order: 0))
        let src2: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc2,
                                                                                   order: 0))

        // context empty → 100% src1; context non-empty → 100% src2.
        let blend: @Sendable (Int, [String]) -> [Double] = { _, context in
            context.isEmpty ? [1.0, 0.0] : [0.0, 1.0]
        }
        let gen = try #require(BlendedGenerator(sources: [src1, src2], blendWeights: blend))

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
    func weights_fixedBlend_combinedCorrectly() throws {
        let mc1 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc1.analyzer().analyze(sequence: ["a"])

        let mc2 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc2.analyzer().analyze(sequence: ["b"])

        let src1: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc1,
                                                                                   order: 1))
        let src2: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc2,
                                                                                   order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [1.0, 1.0] }
        let gen = try #require(BlendedGenerator(sources: [src1, src2], blendWeights: blend))
        let weights = gen.weights(after: .begin)

        #expect(weights.count == 2)

        let aWeight = weights.first { $0.target == .state("a") }?.weight
        let bWeight = weights.first { $0.target == .state("b") }?.weight

        #expect(aWeight != nil)
        #expect(bWeight != nil)
        #expect(abs((aWeight ?? 0) - (bWeight ?? 0)) < 1e-9)
    }

    @Test
    func weights_sourceMissing_redistributes() throws {
        let mc1 = try #require(MarkovChain<String>(maximumOrder: 1))

        // mc1 has no .begin transitions.

        let mc2 = try #require(MarkovChain<String>(maximumOrder: 1))

        mc2.analyzer().analyze(sequence: ["b"])

        let src1: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc1,
                                                                                   order: 1))
        let src2: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc2,
                                                                                   order: 1))
        let blend: @Sendable (Int, [String]) -> [Double] = { _, _ in [0.5, 0.5] }
        let gen = try #require(BlendedGenerator(sources: [src1, src2], blendWeights: blend))
        let weights = gen.weights(after: .begin)

        // Only source2 contributes; its single entry gets weight 1.0.
        #expect(weights.count == 1)
        #expect(weights[0].target == .state("b"))
        #expect(abs(weights[0].weight - 1.0) < 1e-9)
    }
}
