// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct SimpleMarkovChainTests {
}

// MARK: -

extension SimpleMarkovChainTests {
    @Test
    func next_multipleTransitions() {
        var accum = Accumulator()

        accum.increment(inIndex: 1, outIndex: 2)
        accum.increment(inIndex: 1, outIndex: 2)
        accum.increment(inIndex: 1, outIndex: 3)

        let mockRng = MockRandomNumberGenerator(seed: 0)

        var markovChain = SimpleMarkovChain(accumulator: accum,
                                            rng: AnyRandomNumberGenerator(mockRng))

        let result = markovChain.next(after: 1)

        #expect(result == 2 || result == 3)
    }

    @Test
    func next_singleTransition() {
        var accum = Accumulator()

        accum.increment(inIndex: 1, outIndex: 2)
        accum.increment(inIndex: 1, outIndex: 2)
        accum.increment(inIndex: 1, outIndex: 2)

        let mockRng = MockRandomNumberGenerator(seed: 0)

        var markovChain = SimpleMarkovChain(accumulator: accum,
                                            rng: AnyRandomNumberGenerator(mockRng))

        #expect(markovChain.next(after: 1) == 2)
    }

    @Test
    func next_unknownInState() {
        var accum = Accumulator()

        accum.increment(inIndex: 1, outIndex: 2)

        let mockRng = MockRandomNumberGenerator(seed: 0)

        var markovChain = SimpleMarkovChain(accumulator: accum,
                                            rng: AnyRandomNumberGenerator(mockRng))

        #expect(markovChain.next(after: 99) == nil)
    }
}
