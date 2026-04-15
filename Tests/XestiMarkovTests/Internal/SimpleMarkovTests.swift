// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct SimpleMarkovTests {
}

// MARK: -

extension SimpleMarkovTests {
    @Test
    func next_unknownInState() {
        var accum = Accumulator()

        accum.increment(inState: 1, outState: 2)

        let mockRng = MockRandomNumberGenerator(seed: 0)

        var markov = SimpleMarkov(accumulator: accum,
                                  rng: AnyRandomNumberGenerator(mockRng))

        #expect(markov.next(after: 99) == nil)
    }

    @Test
    func next_singleTransition() {
        var accum = Accumulator()

        accum.increment(inState: 1, outState: 2)
        accum.increment(inState: 1, outState: 2)
        accum.increment(inState: 1, outState: 2)

        let mockRng = MockRandomNumberGenerator(seed: 0)

        var markov = SimpleMarkov(accumulator: accum,
                                  rng: AnyRandomNumberGenerator(mockRng))

        #expect(markov.next(after: 1) == 2)
    }

    @Test
    func next_multipleTransitions() {
        var accum = Accumulator()

        accum.increment(inState: 1, outState: 2)
        accum.increment(inState: 1, outState: 2)
        accum.increment(inState: 1, outState: 3)

        let mockRng = MockRandomNumberGenerator(seed: 0)

        var markov = SimpleMarkov(accumulator: accum,
                                  rng: AnyRandomNumberGenerator(mockRng))

        let result = markov.next(after: 1)

        #expect(result == 2 || result == 3)
    }
}
