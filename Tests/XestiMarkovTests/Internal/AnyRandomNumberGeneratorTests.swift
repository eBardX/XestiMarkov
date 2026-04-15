// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct AnyRandomNumberGeneratorTests {
}

// MARK: -

extension AnyRandomNumberGeneratorTests {
    @Test
    func next() {
        let expectedValue = UInt64(666)

        var rng = AnyRandomNumberGenerator(MockRandomNumberGenerator(seed: expectedValue))

        #expect(rng.next() == expectedValue)
    }
}
