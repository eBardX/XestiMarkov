// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
import XestiMarkov

struct SeededRandomNumberGeneratorTests {
}

// MARK: -

extension SeededRandomNumberGeneratorTests {
    @Test
    func differentSeeds_differentSequences() {
        var rng1 = SeededRandomNumberGenerator(seed: 1)
        var rng2 = SeededRandomNumberGenerator(seed: 2)

        let values1 = (0..<10).map { _ in rng1.next() }
        let values2 = (0..<10).map { _ in rng2.next() }

        #expect(values1 != values2)
    }

    @Test
    func knownValues() {
        // SplitMix64 reference values for seed 1234567.
        var rng = SeededRandomNumberGenerator(seed: 1_234_567)

        #expect(rng.next() == 6_457_827_717_110_365_317)
        #expect(rng.next() == 3_203_168_211_198_807_973)
        #expect(rng.next() == 9_817_491_932_198_370_423)
    }

    @Test
    func sameSeed_sameSequence() {
        var rng1 = SeededRandomNumberGenerator(seed: 42)
        var rng2 = SeededRandomNumberGenerator(seed: 42)

        let values1 = (0..<100).map { _ in rng1.next() }
        let values2 = (0..<100).map { _ in rng2.next() }

        #expect(values1 == values2)
    }
}
