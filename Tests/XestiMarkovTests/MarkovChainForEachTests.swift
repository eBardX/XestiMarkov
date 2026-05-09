// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct MarkovChainForEachTests {
}

// MARK: -

extension MarkovChainForEachTests {
    @Test
    func forEach_empty() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        var count = 0

        markovChain.forEach { _ in count += 1 }

        #expect(count == 0) // swiftlint:disable:this empty_count
    }

    @Test
    func forEach_higherOrder() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["a", "b"])

        var sources: [MarkovChain<String>.Transition.Source] = []
        var targets: [MarkovChain<String>.Transition.Target] = []
        var weights: [UInt] = []

        markovChain.forEach { transition in
            sources.append(transition.source)
            targets.append(transition.target)
            weights.append(transition.weight)
        }

        #expect(sources == [.zero, .zero, .begin, .states(["a"]), .states(["b"]), .states(["a"]), .states(["a", "b"])])
        #expect(targets == [.state("a"), .state("b"), .state("a"), .state("b"), .end, .state("b"), .end])
        #expect(weights == [1, 1, 1, 1, 1, 1, 1])
    }

    @Test
    func forEach_multipleOutStates() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["a", "b"])
        analyzer.analyze(sequence: ["a", "c"])

        var sources: [MarkovChain<String>.Transition.Source] = []
        var targets: [MarkovChain<String>.Transition.Target] = []
        var weights: [UInt] = []

        markovChain.forEach { transition in
            sources.append(transition.source)
            targets.append(transition.target)
            weights.append(transition.weight)
        }

        #expect(sources == [.zero, .zero, .zero, .begin, .states(["a"]), .states(["a"]), .states(["b"]), .states(["c"])])
        #expect(targets == [.state("a"), .state("b"), .state("c"), .state("a"), .state("b"), .state("c"), .end, .end])
        #expect(weights == [2, 1, 1, 2, 1, 1, 1, 1])
    }

    @Test
    func forEach_repeatedObservations() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["a", "b"])
        analyzer.analyze(sequence: ["a", "b"])

        var sources: [MarkovChain<String>.Transition.Source] = []
        var targets: [MarkovChain<String>.Transition.Target] = []
        var weights: [UInt] = []

        markovChain.forEach { transition in
            sources.append(transition.source)
            targets.append(transition.target)
            weights.append(transition.weight)
        }

        #expect(sources == [.zero, .zero, .begin, .states(["a"]), .states(["b"])])
        #expect(targets == [.state("a"), .state("b"), .state("a"), .state("b"), .end])
        #expect(weights == [2, 2, 2, 2, 2])
    }

    @Test
    func forEach_singleState() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["a"])

        var sources: [MarkovChain<String>.Transition.Source] = []
        var targets: [MarkovChain<String>.Transition.Target] = []
        var weights: [UInt] = []

        markovChain.forEach { transition in
            sources.append(transition.source)
            targets.append(transition.target)
            weights.append(transition.weight)
        }

        #expect(sources == [.zero, .begin, .states(["a"])])
        #expect(targets == [.state("a"), .state("a"), .end])
        #expect(weights == [1, 1, 1])
    }

    @Test
    func forEach_sortOrder() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["b", "a"])

        var sources: [MarkovChain<String>.Transition.Source] = []
        var targets: [MarkovChain<String>.Transition.Target] = []
        var weights: [UInt] = []

        markovChain.forEach { transition in
            sources.append(transition.source)
            targets.append(transition.target)
            weights.append(transition.weight)
        }

        #expect(sources == [.zero, .zero, .begin, .states(["a"]), .states(["b"])])
        #expect(targets == [.state("a"), .state("b"), .state("b"), .end, .state("a")])
        #expect(weights == [1, 1, 1, 1, 1])
    }

    @Test
    func forEach_trained() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["a", "b", "a"])

        var count = 0

        markovChain.forEach { _ in count += 1 }

        #expect(count > 0) // swiftlint:disable:this empty_count
    }
}
