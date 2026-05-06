// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainAnalyzerTests {
}

// MARK: -

extension MarkovChainAnalyzerTests {
    @Test
    func analyzeSequence_empty() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: [])

        let snapshot = analyzer.markovChain.snapshot

        #expect(snapshot.accumulator.isEmpty)
        #expect(snapshot.inContextMap.isEmpty)
        #expect(snapshot.outContextMap.isEmpty)
    }

    @Test
    func analyzeSequence_ints() throws {
        let states = [7, 1, 4, 8, 6, 7, 5, 3, 0, 9,
                      6, 1, 9, 5, 8, 3, 6, 4, 7, 2,
                      9, 2, 1, 1, 5, 9, 4, 2]
        let accExpectedCount = 94
        let ismExpectedCount = 67
        let osmExpectedCount = 11

        let markovChain = try #require(MarkovChain<Int>(maximumOrder: 3))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: states)

        let snapshot = analyzer.markovChain.snapshot

        #expect(snapshot.accumulator.count == accExpectedCount)
        #expect(snapshot.inContextMap.count == ismExpectedCount)
        #expect(snapshot.outContextMap.count == osmExpectedCount)
    }

    @Test
    func analyzeSequence_strings() throws {
        let states = ["this", "is", "a", "test",
                      "this", "is", "only", "a", "test",
                      "if", "this", "had", "been", "the", "real", "deal",
                      "who", "knows"]
        let accExpectedCount = 30
        let ismExpectedCount = 15
        let osmExpectedCount = 14
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: states)

        let snapshot = analyzer.markovChain.snapshot

        #expect(snapshot.accumulator.count == accExpectedCount)
        #expect(snapshot.inContextMap.count == ismExpectedCount)
        #expect(snapshot.outContextMap.count == osmExpectedCount)
    }

    @Test
    func analyzeSequences_empty() throws {
        let markovChain = try #require(MarkovChain<Int>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequences: [])

        let snapshot = analyzer.markovChain.snapshot

        #expect(snapshot.accumulator.isEmpty)
        #expect(snapshot.inContextMap.isEmpty)
        #expect(snapshot.outContextMap.isEmpty)
    }

    @Test
    func analyzeSequences_singleSequence() throws {
        let sequence = [7, 1, 4, 8, 6, 7, 5, 3, 0, 9,
                        6, 1, 9, 5, 8, 3, 6, 4, 7, 2,
                        9, 2, 1, 1, 5, 9, 4, 2]
        let expectedMarkovChain = try #require(MarkovChain<Int>(maximumOrder: 3))

        expectedMarkovChain.analyzer().analyze(sequence: sequence)

        let expectedSnapshot = expectedMarkovChain.snapshot
        let actualMarkovChain = try #require(MarkovChain<Int>(maximumOrder: 3))

        actualMarkovChain.analyzer().analyze(sequences: [sequence])

        let actualSnapshot = actualMarkovChain.snapshot

        #expect(actualSnapshot.accumulator.count == expectedSnapshot.accumulator.count)
        #expect(actualSnapshot.inContextMap.count == expectedSnapshot.inContextMap.count)
        #expect(actualSnapshot.outContextMap.count == expectedSnapshot.outContextMap.count)
    }

    @Test
    func analyzeSequences_multipleSequences() throws {
        let sequences: [[String]] = [["this", "is", "a", "test"],
                                     ["this", "is", "only", "a", "test"],
                                     ["if", "this", "had", "been", "the", "real", "deal"],
                                     ["who", "knows"]]
        let expectedMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let expectedAnalyzer = expectedMarkovChain.analyzer()

        for sequence in sequences {
            expectedAnalyzer.analyze(sequence: sequence)
        }

        let expectedSnapshot = expectedMarkovChain.snapshot
        let actualMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        actualMarkovChain.analyzer().analyze(sequences: sequences)

        let actualSnapshot = actualMarkovChain.snapshot

        #expect(actualSnapshot.accumulator.count == expectedSnapshot.accumulator.count)
        #expect(actualSnapshot.inContextMap.count == expectedSnapshot.inContextMap.count)
        #expect(actualSnapshot.outContextMap.count == expectedSnapshot.outContextMap.count)
    }

    @Test
    func analyzeSequences_notEquivalentToConcatenation() throws {
        let sequences = [["a", "b"], ["c", "d"]]
        let concatenated = sequences.flatMap { $0 }
        let sequencesMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        sequencesMarkovChain.analyzer().analyze(sequences: sequences)

        let concatenatedMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        concatenatedMarkovChain.analyzer().analyze(sequence: concatenated)

        #expect(sequencesMarkovChain.snapshot.accumulator.count != concatenatedMarkovChain.snapshot.accumulator.count)
    }

    @Test
    func merge_additiveWeights() throws {
        let expectedMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        expectedMarkovChain.analyzer().analyze(sequence: ["a", "b"])
        expectedMarkovChain.analyzer().analyze(sequence: ["a", "b"])

        let expectedSnapshot = expectedMarkovChain.snapshot
        let actualMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        actualMarkovChain.analyzer().analyze(sequence: ["a", "b"])
        actualMarkovChain.analyzer().merge(actualMarkovChain)

        let actualSnapshot = actualMarkovChain.snapshot

        #expect(actualSnapshot.accumulator.count == expectedSnapshot.accumulator.count)
        #expect(actualSnapshot.inContextMap.count == expectedSnapshot.inContextMap.count)
        #expect(actualSnapshot.outContextMap.count == expectedSnapshot.outContextMap.count)
    }

    @Test
    func merge_basicCorrectness() throws {
        let seqA = ["a", "b", "c"]
        let seqB = ["d", "e", "f"]
        let expectedMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        expectedMarkovChain.analyzer().analyze(sequence: seqA)
        expectedMarkovChain.analyzer().analyze(sequence: seqB)

        let expectedSnapshot = expectedMarkovChain.snapshot
        let otherMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        otherMarkovChain.analyzer().analyze(sequence: seqB)

        let actualMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        actualMarkovChain.analyzer().analyze(sequence: seqA)
        actualMarkovChain.analyzer().merge(otherMarkovChain)

        let actualSnapshot = actualMarkovChain.snapshot

        #expect(actualSnapshot.accumulator.count == expectedSnapshot.accumulator.count)
        #expect(actualSnapshot.inContextMap.count == expectedSnapshot.inContextMap.count)
        #expect(actualSnapshot.outContextMap.count == expectedSnapshot.outContextMap.count)
    }

    @Test
    func merge_commutativity() throws {
        let markovChainA = try #require(MarkovChain<String>(maximumOrder: 1))
        let markovChainB = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChainA.analyzer().analyze(sequence: ["a", "b"])
        markovChainB.analyzer().analyze(sequence: ["c", "d"])

        let ab = try #require(MarkovChain<String>(maximumOrder: 1))

        ab.analyzer().analyze(sequence: ["a", "b"])
        ab.analyzer().merge(markovChainB)

        let ba = try #require(MarkovChain<String>(maximumOrder: 1))

        ba.analyzer().analyze(sequence: ["c", "d"])
        ba.analyzer().merge(markovChainA)

        let abSnapshot = ab.snapshot
        let baSnapshot = ba.snapshot

        #expect(abSnapshot.accumulator.count == baSnapshot.accumulator.count)
        #expect(abSnapshot.inContextMap.count == baSnapshot.inContextMap.count)
        #expect(abSnapshot.outContextMap.count == baSnapshot.outContextMap.count)
    }

    @Test
    func merge_emptySource() throws {
        let beforeMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        beforeMarkovChain.analyzer().analyze(sequence: ["a", "b"])

        let beforeSnapshot = beforeMarkovChain.snapshot
        let emptyMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        beforeMarkovChain.analyzer().merge(emptyMarkovChain)

        let afterSnapshot = beforeMarkovChain.snapshot

        #expect(afterSnapshot.accumulator.count == beforeSnapshot.accumulator.count)
        #expect(afterSnapshot.inContextMap.count == beforeSnapshot.inContextMap.count)
        #expect(afterSnapshot.outContextMap.count == beforeSnapshot.outContextMap.count)
    }

    @Test
    func merge_emptyTarget() throws {
        let beforeMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        beforeMarkovChain.analyzer().analyze(sequence: ["a", "b"])

        let beforeSnapshot = beforeMarkovChain.snapshot
        let emptyMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        emptyMarkovChain.analyzer().merge(beforeMarkovChain)

        let afterSnapshot = emptyMarkovChain.snapshot

        #expect(afterSnapshot.accumulator.count == beforeSnapshot.accumulator.count)
        #expect(afterSnapshot.inContextMap.count == beforeSnapshot.inContextMap.count)
        #expect(afterSnapshot.outContextMap.count == beforeSnapshot.outContextMap.count)
    }

    @Test
    func merge_maximumOrderMismatch() throws {
        let sequence = ["a", "b", "c"]
        let source = try #require(MarkovChain<String>(maximumOrder: 2))

        source.analyzer().analyze(sequence: sequence)

        let expectedMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        expectedMarkovChain.analyzer().analyze(sequence: sequence)

        let expectedSnapshot = expectedMarkovChain.snapshot
        let actualMarkovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        actualMarkovChain.analyzer().merge(source)

        let actualSnapshot = actualMarkovChain.snapshot

        #expect(actualSnapshot.accumulator.count == expectedSnapshot.accumulator.count)
        #expect(actualSnapshot.inContextMap.count == expectedSnapshot.inContextMap.count)
        #expect(actualSnapshot.outContextMap.count == expectedSnapshot.outContextMap.count)
    }
}
