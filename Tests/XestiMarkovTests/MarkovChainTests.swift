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

        analyzer.analyze(["a", "b", "c", "a", "b"])

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
    func forEach_empty() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        var count = 0

        markovChain.forEach { _ in count += 1 }

        #expect(count == 0) // swiftlint:disable:this empty_count
    }

    @Test
    func forEach_trained() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        let analyzer = markovChain.analyzer()

        analyzer.analyze(["a", "b", "a"])

        var count = 0

        markovChain.forEach { _ in count += 1 }

        #expect(count > 0) // swiftlint:disable:this empty_count
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
}
