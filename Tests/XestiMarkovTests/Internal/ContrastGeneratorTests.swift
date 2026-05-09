// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct ContrastGeneratorTests {
}

// MARK: -

extension ContrastGeneratorTests {
    @Test
    func next_highContrast_favoursMostProbable() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        // begin → "a" (3×), begin → "b" (1×)
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["b", "x"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))

        // With contrast 4.0 the distribution sharpens dramatically toward "a".
        // Seed 0 → roll ≈ 0.0 → selects "a" (the first entry in sorted order).
        var gen = ContrastGenerator(source: source,
                                    contrast: 4.0,
                                    rng: AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0)))

        #expect(gen.next(after: []) == "a")
    }

    @Test
    func next_lowContrast_makesLessProbableReachable() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        // "a" has 3× frequency, "b" has 1×.
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["b", "x"])

        // Without contrast, "a" weight=3, "b" weight=1, total=4.
        // With contrast=0.25 (flatten), normalised probs (0.75, 0.25) are
        // raised to 1/0.25 = 4: (0.316…, 0.25). "b"'s share increases.
        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))

        let gen = ContrastGenerator(source: source, contrast: 0.25)
        let weights = gen.weights(after: .begin)
        let aWeight = weights.first { $0.target == .state("a") }?.weight ?? 0
        let bWeight = weights.first { $0.target == .state("b") }?.weight ?? 0

        // Ratio a/b with contrast 0.25 should be much closer to 1 than raw 3.
        let flatRatio = aWeight / bWeight
        let rawRatio = 3.0

        #expect(flatRatio < rawRatio)
    }

    @Test
    func next_neutralContrast_matchesSourceBehavior() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "b", "c"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))

        // Both generators use the same mock RNG seed.
        var plain = ContrastGenerator(source: source,
                                      contrast: 1.0,
                                      rng: AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0)))

        let mockRNG = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: 0))

        var direct: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1,
                                                                                     rng: mockRNG))

        // Neutral contrast leaves probabilities unchanged, so the same roll
        // produces the same state.
        #expect(plain.next(after: []) == direct.next(after: []))
    }

    @Test
    func weights_highContrast_sharpensDistribution() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["b", "x"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let gen = ContrastGenerator(source: source, contrast: 4.0)
        let weights = gen.weights(after: .begin)
        let aWeight = weights.first { $0.target == .state("a") }?.weight ?? 0
        let bWeight = weights.first { $0.target == .state("b") }?.weight ?? 0

        // High contrast increases "a"'s dominance over raw 3:1 ratio.
        let contrastRatio = aWeight / bWeight

        #expect(contrastRatio > 3.0)
    }

    @Test
    func weights_lowContrast_flattensDistribution() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["b", "x"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let gen = ContrastGenerator(source: source, contrast: 0.25)
        let weights = gen.weights(after: .begin)
        let aWeight = weights.first { $0.target == .state("a") }?.weight ?? 0
        let bWeight = weights.first { $0.target == .state("b") }?.weight ?? 0
        let flatRatio = aWeight / bWeight

        #expect(flatRatio < 3.0)  // flatter than raw 3:1
    }

    @Test
    func weights_neutralContrast_identityTransform() throws {
        let mc = try #require(MarkovChain<String>(maximumOrder: 1))

        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["a", "x"])
        mc.analyzer().analyze(sequence: ["b", "x"])

        let source: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: mc,
                                                                                     order: 1))
        let gen = ContrastGenerator(source: source, contrast: 1.0)
        let weights = gen.weights(after: .begin)
        let aWeight = weights.first { $0.target == .state("a") }?.weight ?? 0
        let bWeight = weights.first { $0.target == .state("b") }?.weight ?? 0

        // With contrast 1.0, normalised probs are raised to 1/1 = 1 → unchanged.
        // a:b should be 0.75:0.25 = 3:1.
        #expect(abs(aWeight / bWeight - 3.0) < 1e-9)
    }
}
