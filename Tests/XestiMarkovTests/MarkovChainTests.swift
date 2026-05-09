// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct MarkovChainTests {
}

// MARK: -

extension MarkovChainTests {
    @Test
    func codable() throws {
        let original = try #require(MarkovChain<String>(maximumOrder: 2))

        let analyzer = original.analyzer()

        analyzer.analyze(sequence: ["a", "b", "c", "a", "b"])

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MarkovChain<String>.self, from: data)
        let origSnapshot = original.snapshot
        let decodedSnapshot = decoded.snapshot

        #expect(decoded.maximumOrder == original.maximumOrder)
        #expect(decodedSnapshot.accumulator.count == origSnapshot.accumulator.count)
        #expect(decodedSnapshot.inContextMap.count == origSnapshot.inContextMap.count)
        #expect(decodedSnapshot.outContextMap.count == origSnapshot.outContextMap.count)
    }

    @Test
    func init_failure() {
        #expect(MarkovChain<String>(maximumOrder: 0) == nil)
        #expect(MarkovChain<String>(maximumOrder: -1) == nil)
    }

    @Test
    func init_success() throws {
        let expectedValue = 3

        let markovChain = try #require(MarkovChain<String>(maximumOrder: expectedValue))

        let snapshot = markovChain.snapshot

        #expect(markovChain.maximumOrder == expectedValue)
        #expect(snapshot.accumulator.isEmpty)
        #expect(snapshot.inContextMap.isEmpty)
        #expect(snapshot.outContextMap.isEmpty)
    }

    @Test
    func isEmpty_afterAnalysis() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a"])

        #expect(!markovChain.isEmpty)
    }

    @Test
    func isEmpty_newChain() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.isEmpty)
    }

    @Test
    func stateCount_distinctStates() throws {
        let expectedValue = 3
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["c", "a", "b", "a"])

        #expect(markovChain.stateCount == expectedValue)
    }

    @Test
    func stateCount_empty() throws {
        let expectedValue = 0
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.stateCount == expectedValue)
    }

    @Test
    func stateCount_matchesStatesCount() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["c", "a", "b", "a"])

        #expect(markovChain.stateCount == markovChain.states.count)
    }

    @Test
    func states_empty() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.states.isEmpty)
    }

    @Test
    func states_noDuplicates() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "a", "a"])

        #expect(markovChain.states == ["a"])
    }

    @Test
    func states_sorted() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["c", "a", "b"])

        #expect(markovChain.states == ["a", "b", "c"])
    }

    @Test
    func transitionCount_empty() throws {
        let expectedValue = 0
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.transitionCount == expectedValue)
    }

    @Test
    func transitionCount_matchesForEach() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var forEachCount = 0

        markovChain.analyzer().analyze(sequence: ["a", "b", "c", "a", "b"])

        markovChain.forEach { _ in forEachCount += 1 }

        #expect(markovChain.transitionCount == forEachCount)
    }
}
