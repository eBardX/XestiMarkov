// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct MarkovForEachTests {
}

// MARK: -

extension MarkovForEachTests {
    @Test
    func forEach_empty() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))
        var count = 0

        markov.forEach { _, _, _ in count += 1 }

        #expect(count == 0) // swiftlint:disable:this empty_count
    }

    @Test
    func forEach_higherOrder() throws {
        let markov = try #require(Markov<String>(maximumOrder: 2))
        let analyzer = markov.analyzer()

        analyzer.analyze(["a", "b"])

        var inStates: [Markov<String>.State] = []
        var outStates: [Markov<String>.State] = []
        var weights: [UInt] = []

        markov.forEach { inState, outState, weight in
            inStates.append(inState)
            outStates.append(outState)
            weights.append(weight)
        }

        let seqBeginA = makeMarkovState([.begin, .single("a")] as [Markov<String>.State])
        let seqAB = makeMarkovState([.single("a"), .single("b")] as [Markov<String>.State])

        #expect(inStates == [.zero, .zero, .begin, .single("a"), .single("b"), seqBeginA, seqAB])
        #expect(outStates == [.single("a"), .single("b"), .single("a"), .single("b"), .end, .single("b"), .end])
        #expect(weights == [1, 1, 1, 1, 1, 1, 1])
    }

    @Test
    func forEach_multipleOutStates() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))
        let analyzer = markov.analyzer()

        analyzer.analyze(["a", "b"])
        analyzer.analyze(["a", "c"])

        var inStates: [Markov<String>.State] = []
        var outStates: [Markov<String>.State] = []
        var weights: [UInt] = []

        markov.forEach { inState, outState, weight in
            inStates.append(inState)
            outStates.append(outState)
            weights.append(weight)
        }

        #expect(inStates == [.zero, .zero, .zero, .begin, .single("a"), .single("a"), .single("b"), .single("c")])
        #expect(outStates == [.single("a"), .single("b"), .single("c"), .single("a"), .single("b"), .single("c"), .end, .end])
        #expect(weights == [2, 1, 1, 2, 1, 1, 1, 1])
    }

    @Test
    func forEach_repeatedObservations() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))
        let analyzer = markov.analyzer()

        analyzer.analyze(["a", "b"])
        analyzer.analyze(["a", "b"])

        var inStates: [Markov<String>.State] = []
        var outStates: [Markov<String>.State] = []
        var weights: [UInt] = []

        markov.forEach { inState, outState, weight in
            inStates.append(inState)
            outStates.append(outState)
            weights.append(weight)
        }

        #expect(inStates == [.zero, .zero, .begin, .single("a"), .single("b")])
        #expect(outStates == [.single("a"), .single("b"), .single("a"), .single("b"), .end])
        #expect(weights == [2, 2, 2, 2, 2])
    }

    @Test
    func forEach_singleEvent() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))
        let analyzer = markov.analyzer()

        analyzer.analyze(["a"])

        var inStates: [Markov<String>.State] = []
        var outStates: [Markov<String>.State] = []
        var weights: [UInt] = []

        markov.forEach { inState, outState, weight in
            inStates.append(inState)
            outStates.append(outState)
            weights.append(weight)
        }

        #expect(inStates == [.zero, .begin, .single("a")])
        #expect(outStates == [.single("a"), .single("a"), .end])
        #expect(weights == [1, 1, 1])
    }

    @Test
    func forEach_sortOrder() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))
        let analyzer = markov.analyzer()

        analyzer.analyze(["b", "a"])

        var inStates: [Markov<String>.State] = []
        var outStates: [Markov<String>.State] = []
        var weights: [UInt] = []

        markov.forEach { inState, outState, weight in
            inStates.append(inState)
            outStates.append(outState)
            weights.append(weight)
        }

        #expect(inStates == [.zero, .zero, .begin, .single("a"), .single("b")])
        #expect(outStates == [.single("a"), .single("b"), .single("b"), .end, .single("a")])
        #expect(weights == [1, 1, 1, 1, 1])
    }
}
