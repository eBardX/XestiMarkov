// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct AccumulatorKeyTests {
}

// MARK: -

extension AccumulatorKeyTests {
    @Test
    func comparable() {
        let a = Accumulator.Key(inIndex: 1, outIndex: 2)
        let b = Accumulator.Key(inIndex: 1, outIndex: 3)
        let c = Accumulator.Key(inIndex: 2, outIndex: 0)

        #expect(a < b)
        #expect(a < c)
        #expect(b < c)
        #expect(!(c < a))
        #expect(!(a < a))   // swiftlint:disable:this identical_operands
    }

    @Test
    func equality() {
        let a = Accumulator.Key(inIndex: 3, outIndex: 7)
        let b = Accumulator.Key(inIndex: 3, outIndex: 7)

        #expect(a == b)
    }

    @Test
    func hashable() {
        let a = Accumulator.Key(inIndex: 1, outIndex: 2)
        let b = Accumulator.Key(inIndex: 1, outIndex: 2)
        let c = Accumulator.Key(inIndex: 3, outIndex: 4)
        let set: Set<Accumulator.Key> = [a, b, c]

        #expect(set.count == 2)
    }

    @Test
    func inequality() {
        let a = Accumulator.Key(inIndex: 1, outIndex: 2)
        let b = Accumulator.Key(inIndex: 1, outIndex: 3)
        let c = Accumulator.Key(inIndex: 2, outIndex: 2)

        #expect(a != b)
        #expect(a != c)
        #expect(b != c)
    }

    @Test
    func `init`() {
        let key = Accumulator.Key(inIndex: 3, outIndex: 7)

        #expect(key.inIndex == 3)
        #expect(key.outIndex == 7)
    }
}
