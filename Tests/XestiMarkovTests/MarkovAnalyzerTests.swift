// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovAnalyzerTests {
}

// MARK: -

extension MarkovAnalyzerTests {
    @Test
    func analyze_ints() throws {
        let events = [7, 1, 4, 8, 6, 7, 5, 3, 0, 9,
                      6, 1, 9, 5, 8, 3, 6, 4, 7, 2,
                      9, 2, 1, 1, 5, 9, 4, 2]
        let accExpectedValue = 94
        let ismExpectedValue = 67
        let osmExpectedValue = 11

        let markov = try #require(Markov<Int>(maximumOrder: 3))

        let analyzer = markov.analyzer()

        analyzer.analyze(events)

        let snapshot = analyzer.markov.snapshot

        #expect(snapshot.accumulator.count == accExpectedValue)
        #expect(snapshot.inStateMap.count == ismExpectedValue)
        #expect(snapshot.outStateMap.count == osmExpectedValue)
    }

    @Test
    func analyze_strings() throws {
        let events = ["this", "is", "a", "test",
                      "this", "is", "only", "a", "test",
                      "if", "this", "had", "been", "the", "real", "deal",
                      "who", "knows"]
        let accExpectedValue = 30
        let ismExpectedValue = 15
        let osmExpectedValue = 14

        let markov = try #require(Markov<String>(maximumOrder: 1))

        let analyzer = markov.analyzer()

        analyzer.analyze(events)

        let snapshot = analyzer.markov.snapshot

        #expect(snapshot.accumulator.count == accExpectedValue)
        #expect(snapshot.inStateMap.count == ismExpectedValue)
        #expect(snapshot.outStateMap.count == osmExpectedValue)
    }
}
