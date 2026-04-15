// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct MarkovTests {
}

// MARK: -

extension MarkovTests {
    @Test
    func codable() throws {
        let original = try #require(Markov<String>(maximumOrder: 2))

        let analyzer = original.analyzer()

        analyzer.analyze(["a", "b", "c", "a", "b"])

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Markov<String>.self, from: data)

        let origSnapshot = original.snapshot
        let decodedSnapshot = decoded.snapshot

        #expect(decoded.maximumOrder == original.maximumOrder)
        #expect(decodedSnapshot.accumulator.count == origSnapshot.accumulator.count)
        #expect(decodedSnapshot.inStateMap.count == origSnapshot.inStateMap.count)
        #expect(decodedSnapshot.outStateMap.count == origSnapshot.outStateMap.count)
    }

    @Test
    func forEach_empty() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))

        var count = 0

        markov.forEach { _, _, _ in count += 1 }

        #expect(count == 0) // swiftlint:disable:this empty_count
    }

    @Test
    func forEach_trained() throws {
        let markov = try #require(Markov<String>(maximumOrder: 1))

        let analyzer = markov.analyzer()

        analyzer.analyze(["a", "b", "a"])

        var count = 0

        markov.forEach { _, _, _ in count += 1 }

        #expect(count > 0) // swiftlint:disable:this empty_count
    }

    @Test
    func init_failure() {
        #expect(Markov<String>(maximumOrder: 0) == nil)
        #expect(Markov<String>(maximumOrder: -1) == nil)
    }

    @Test
    func init_success() throws {
        let expectedValue = 3

        let markov = try #require(Markov<String>(maximumOrder: expectedValue))

        let snapshot = markov.snapshot

        #expect(markov.maximumOrder == expectedValue)
        #expect(snapshot.accumulator.isEmpty)
        #expect(snapshot.inStateMap.isEmpty)
        #expect(snapshot.outStateMap.isEmpty)
    }
}
