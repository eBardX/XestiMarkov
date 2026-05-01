// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainAnalyzerTests {
}

// MARK: -

extension MarkovChainAnalyzerTests {
    @Test
    func analyze_ints() throws {
        let states = [7, 1, 4, 8, 6, 7, 5, 3, 0, 9,
                      6, 1, 9, 5, 8, 3, 6, 4, 7, 2,
                      9, 2, 1, 1, 5, 9, 4, 2]
        let accExpectedValue = 94
        let ismExpectedValue = 67
        let osmExpectedValue = 11

        let markovChain = try #require(MarkovChain<Int>(maximumOrder: 3))

        let analyzer = markovChain.analyzer()

        analyzer.analyze(states)

        let snapshot = analyzer.markovChain.snapshot

        #expect(snapshot.accumulator.count == accExpectedValue)
        #expect(snapshot.inContextMap.count == ismExpectedValue)
        #expect(snapshot.outContextMap.count == osmExpectedValue)
    }

    @Test
    func analyze_strings() throws {
        let states = ["this", "is", "a", "test",
                      "this", "is", "only", "a", "test",
                      "if", "this", "had", "been", "the", "real", "deal",
                      "who", "knows"]
        let accExpectedValue = 30
        let ismExpectedValue = 15
        let osmExpectedValue = 14

        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        let analyzer = markovChain.analyzer()

        analyzer.analyze(states)

        let snapshot = analyzer.markovChain.snapshot

        #expect(snapshot.accumulator.count == accExpectedValue)
        #expect(snapshot.inContextMap.count == ismExpectedValue)
        #expect(snapshot.outContextMap.count == osmExpectedValue)
    }
}
