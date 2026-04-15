// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct AccumulatorTests {
}

// MARK: -

extension AccumulatorTests {
    @Test
    func codable_empty() throws {
        let accum = Accumulator()
        let data = try JSONEncoder().encode(accum)
        let decoded = try JSONDecoder().decode(Accumulator.self, from: data)

        #expect(decoded.weightMap.isEmpty)
        #expect(decoded.extractElements(for: 3).isEmpty)
    }

    @Test
    func codable_notEmpty() throws {
        let expectedValue3: ExtractResult = [(makeAccumulatorKey(3, 3), 1),
                                             (makeAccumulatorKey(3, 5), 1)]
        let expectedValue5: ExtractResult = [(makeAccumulatorKey(5, 2), 1),
                                             (makeAccumulatorKey(5, 3), 1),
                                             (makeAccumulatorKey(5, 4), 2)]
        let expectedValue7: ExtractResult = [(makeAccumulatorKey(7, 2), 1),
                                             (makeAccumulatorKey(7, 3), 2)]

        var accum = Accumulator()

        accum.increment(inState: 3, outState: 5)
        accum.increment(inState: 5, outState: 4)
        accum.increment(inState: 7, outState: 3)
        accum.increment(inState: 5, outState: 4)
        accum.increment(inState: 7, outState: 3)
        accum.increment(inState: 5, outState: 2)
        accum.increment(inState: 5, outState: 3)
        accum.increment(inState: 7, outState: 2)
        accum.increment(inState: 3, outState: 3)

        let data = try JSONEncoder().encode(accum)
        let decoded = try JSONDecoder().decode(Accumulator.self, from: data)

        #expect(decoded.weightMap == accum.weightMap)
        #expect(decoded.extractElements(for: 3) == expectedValue3)
        #expect(decoded.extractElements(for: 5) == expectedValue5)
        #expect(decoded.extractElements(for: 7) == expectedValue7)
        #expect(decoded.extractElements(for: 99).isEmpty)
    }

    @Test
    func count_empty() {
        let expectedValue = 0

        let accum = Accumulator()

        #expect(accum.count == expectedValue)
    }

    @Test
    func count_notEmpty() {
        let expectedValue = 7

        var accum = Accumulator()

        accum.increment(inState: 3, outState: 5)
        accum.increment(inState: 5, outState: 4)
        accum.increment(inState: 7, outState: 3)
        accum.increment(inState: 5, outState: 4)
        accum.increment(inState: 7, outState: 3)
        accum.increment(inState: 5, outState: 2)
        accum.increment(inState: 5, outState: 3)
        accum.increment(inState: 7, outState: 2)
        accum.increment(inState: 3, outState: 3)

        #expect(accum.count == expectedValue)
    }

    @Test
    func extractElements_empty() {
        let accum = Accumulator()

        #expect(accum.extractElements(for: 3).isEmpty)
        #expect(accum.extractElements(for: 5).isEmpty)
        #expect(accum.extractElements(for: 7).isEmpty)
    }

    @Test
    func extractElements_notEmpty() {
        let expectedValue3: ExtractResult = [(makeAccumulatorKey(3, 3), 1),
                                             (makeAccumulatorKey(3, 5), 1)]
        let expectedValue5: ExtractResult = [(makeAccumulatorKey(5, 2), 1),
                                             (makeAccumulatorKey(5, 3), 1),
                                             (makeAccumulatorKey(5, 4), 2)]
        let expectedValue7: ExtractResult = [(makeAccumulatorKey(7, 2), 1),
                                             (makeAccumulatorKey(7, 3), 2)]

        var accum = Accumulator()

        accum.increment(inState: 3, outState: 5)
        accum.increment(inState: 5, outState: 4)
        accum.increment(inState: 7, outState: 3)
        accum.increment(inState: 5, outState: 4)
        accum.increment(inState: 7, outState: 3)
        accum.increment(inState: 5, outState: 2)
        accum.increment(inState: 5, outState: 3)
        accum.increment(inState: 7, outState: 2)
        accum.increment(inState: 3, outState: 3)

        #expect(accum.extractElements(for: 3) == expectedValue3)
        #expect(accum.extractElements(for: 5) == expectedValue5)
        #expect(accum.extractElements(for: 7) == expectedValue7)
    }

    @Test
    func isEmpty_empty() {
        #expect(Accumulator().isEmpty)
    }

    @Test
    func isEmpty_notEmpty() {
        var accum = Accumulator()

        accum.increment(inState: 1, outState: 2)

        #expect(!accum.isEmpty)
    }
}
