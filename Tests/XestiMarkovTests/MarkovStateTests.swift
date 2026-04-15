// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct MarkovStateTests {
}

// MARK: -

extension MarkovStateTests {
    @Test
    func append_limit() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let end: Markov<String>.State = .end
        let bilbo: Markov<String>.State = .single("bilbo")
        let frodo: Markov<String>.State = .single("frodo")
        let seq2: Markov<String>.State = makeMarkovState([begin, bilbo])
        let seq3: Markov<String>.State = makeMarkovState([begin, bilbo, frodo])
        let seq4: Markov<String>.State = makeMarkovState([begin, bilbo, frodo, end])

        verifyMarkovStateAppend(seq3, end, end, limit: 1)
        verifyMarkovStateAppend(seq3, single, single, limit: 1)
        verifyMarkovStateAppend(seq2, begin, bilbo, limit: 1)
        verifyMarkovStateAppend(seq2, end, end, limit: 1)
        verifyMarkovStateAppend(seq2, single, single, limit: 1)
        verifyMarkovStateAppend(begin, end, end, limit: 1)
        verifyMarkovStateAppend(begin, single, single, limit: 1)
        verifyMarkovStateAppend(single, end, end, limit: 1)

        verifyMarkovStateAppend(seq3, end, makeMarkovState([frodo, end]), limit: 2)
        verifyMarkovStateAppend(seq3, single, makeMarkovState([frodo, single]), limit: 2)
        verifyMarkovStateAppend(seq2, begin, makeMarkovState([begin, bilbo]), limit: 2)
        verifyMarkovStateAppend(seq2, end, makeMarkovState([bilbo, end]), limit: 2)
        verifyMarkovStateAppend(seq2, single, makeMarkovState([bilbo, single]), limit: 2)
        verifyMarkovStateAppend(begin, end, makeMarkovState([begin, end]), limit: 2)
        verifyMarkovStateAppend(begin, single, makeMarkovState([begin, single]), limit: 2)
        verifyMarkovStateAppend(single, end, makeMarkovState([single, end]), limit: 2)

        verifyMarkovStateAppend(seq3, end, makeMarkovState([bilbo, frodo, end]), limit: 3)
        verifyMarkovStateAppend(seq3, single, makeMarkovState([bilbo, frodo, single]), limit: 3)
        verifyMarkovStateAppend(seq2, begin, makeMarkovState([begin, bilbo]), limit: 3)
        verifyMarkovStateAppend(seq2, end, makeMarkovState([begin, bilbo, end]), limit: 3)
        verifyMarkovStateAppend(seq2, single, makeMarkovState([begin, bilbo, single]), limit: 3)
        verifyMarkovStateAppend(begin, end, makeMarkovState([begin, end]), limit: 3)
        verifyMarkovStateAppend(begin, single, makeMarkovState([begin, single]), limit: 3)
        verifyMarkovStateAppend(single, end, makeMarkovState([single, end]), limit: 3)

        verifyMarkovStateAppend(seq3, end, seq4, limit: 4)
        verifyMarkovStateAppend(seq3, single, makeMarkovState([begin, bilbo, frodo, single]), limit: 4)
        verifyMarkovStateAppend(seq2, begin, makeMarkovState([begin, bilbo]), limit: 4)
        verifyMarkovStateAppend(seq2, end, makeMarkovState([begin, bilbo, end]), limit: 4)
        verifyMarkovStateAppend(seq2, single, makeMarkovState([begin, bilbo, single]), limit: 4)
        verifyMarkovStateAppend(begin, end, makeMarkovState([begin, end]), limit: 4)
        verifyMarkovStateAppend(begin, single, makeMarkovState([begin, single]), limit: 4)
        verifyMarkovStateAppend(single, end, makeMarkovState([single, end]), limit: 4)

        verifyMarkovStateAppend(seq3, end, makeMarkovState([begin, bilbo, frodo, end]), limit: 5)
        verifyMarkovStateAppend(seq3, single, makeMarkovState([begin, bilbo, frodo, single]), limit: 5)
        verifyMarkovStateAppend(seq2, begin, makeMarkovState([begin, bilbo]), limit: 5)
        verifyMarkovStateAppend(seq2, end, makeMarkovState([begin, bilbo, end]), limit: 5)
        verifyMarkovStateAppend(seq2, single, makeMarkovState([begin, bilbo, single]), limit: 5)
        verifyMarkovStateAppend(begin, end, makeMarkovState([begin, end]), limit: 5)
        verifyMarkovStateAppend(begin, single, makeMarkovState([begin, single]), limit: 5)
        verifyMarkovStateAppend(single, end, makeMarkovState([single, end]), limit: 5)
    }

    @Test
    func append_sequence() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let zero: Markov<String>.State = .zero
        let end: Markov<String>.State = .end
        let bilbo: Markov<String>.State = .single("bilbo")
        let frodo: Markov<String>.State = .single("frodo")
        let seq0: Markov<String>.State = makeMarkovState([])
        let seq1: Markov<String>.State = makeMarkovState([begin])
        let seq2: Markov<String>.State = makeMarkovState([begin, bilbo])
        let seq3: Markov<String>.State = makeMarkovState([begin, bilbo, frodo])
        let seq4: Markov<String>.State = makeMarkovState([begin, bilbo, frodo, end])

        verifyMarkovStateAppend(begin, seq0, begin)
        verifyMarkovStateAppend(begin, seq1, begin)
        verifyMarkovStateAppend(begin, seq2, begin)
        verifyMarkovStateAppend(begin, seq3, begin)
        verifyMarkovStateAppend(begin, seq4, begin)

        verifyMarkovStateAppend(end, seq0, end)
        verifyMarkovStateAppend(end, seq1, end)
        verifyMarkovStateAppend(end, seq2, end)
        verifyMarkovStateAppend(end, seq3, end)
        verifyMarkovStateAppend(end, seq4, end)

        verifyMarkovStateAppend(single, seq0, single)
        verifyMarkovStateAppend(single, seq1, single)
        verifyMarkovStateAppend(single, seq2, single)
        verifyMarkovStateAppend(single, seq3, single)
        verifyMarkovStateAppend(single, seq4, single)

        verifyMarkovStateAppend(zero, seq0, zero)
        verifyMarkovStateAppend(zero, seq1, zero)
        verifyMarkovStateAppend(zero, seq2, zero)
        verifyMarkovStateAppend(zero, seq3, zero)
        verifyMarkovStateAppend(zero, seq4, zero)

        verifyMarkovStateAppend(seq0, begin, begin)
        verifyMarkovStateAppend(seq1, begin, begin)
        verifyMarkovStateAppend(seq2, begin, seq2)
        verifyMarkovStateAppend(seq3, begin, seq3)
        verifyMarkovStateAppend(seq4, begin, seq4)

        verifyMarkovStateAppend(seq0, end, end)
        verifyMarkovStateAppend(seq1, end, makeMarkovState([begin, end]))
        verifyMarkovStateAppend(seq2, end, makeMarkovState([begin, bilbo, end]))
        verifyMarkovStateAppend(seq3, end, makeMarkovState([begin, bilbo, frodo, end]))
        verifyMarkovStateAppend(seq4, end, seq4)

        verifyMarkovStateAppend(seq0, single, single)
        verifyMarkovStateAppend(seq1, single, makeMarkovState([begin, single]))
        verifyMarkovStateAppend(seq2, single, makeMarkovState([begin, bilbo, single]))
        verifyMarkovStateAppend(seq3, single, makeMarkovState([begin, bilbo, frodo, single]))
        verifyMarkovStateAppend(seq4, single, seq4)

        verifyMarkovStateAppend(seq0, zero, zero)
        verifyMarkovStateAppend(seq1, zero, begin)
        verifyMarkovStateAppend(seq2, zero, seq2)
        verifyMarkovStateAppend(seq3, zero, seq3)
        verifyMarkovStateAppend(seq4, zero, seq4)

        verifyMarkovStateAppend(seq0, seq0, zero)
        verifyMarkovStateAppend(seq1, seq0, begin)
        verifyMarkovStateAppend(seq2, seq0, seq2)
        verifyMarkovStateAppend(seq3, seq0, seq3)
        verifyMarkovStateAppend(seq4, seq0, seq4)

        verifyMarkovStateAppend(seq0, seq1, zero)
        verifyMarkovStateAppend(seq1, seq1, begin)
        verifyMarkovStateAppend(seq2, seq1, seq2)
        verifyMarkovStateAppend(seq3, seq1, seq3)
        verifyMarkovStateAppend(seq4, seq1, seq4)

        verifyMarkovStateAppend(seq0, seq2, zero)
        verifyMarkovStateAppend(seq1, seq2, begin)
        verifyMarkovStateAppend(seq2, seq2, seq2)
        verifyMarkovStateAppend(seq3, seq2, seq3)
        verifyMarkovStateAppend(seq4, seq2, seq4)

        verifyMarkovStateAppend(seq0, seq3, zero)
        verifyMarkovStateAppend(seq1, seq3, begin)
        verifyMarkovStateAppend(seq2, seq3, seq2)
        verifyMarkovStateAppend(seq3, seq3, seq3)
        verifyMarkovStateAppend(seq4, seq3, seq4)

        verifyMarkovStateAppend(seq0, seq4, zero)
        verifyMarkovStateAppend(seq1, seq4, begin)
        verifyMarkovStateAppend(seq2, seq4, seq2)
        verifyMarkovStateAppend(seq3, seq4, seq3)
        verifyMarkovStateAppend(seq4, seq4, seq4)
    }

    @Test
    func append_simple() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let zero: Markov<String>.State = .zero
        let end: Markov<String>.State = .end

        verifyMarkovStateAppend(begin, begin, begin)
        verifyMarkovStateAppend(begin, end, makeMarkovState([begin, end]))
        verifyMarkovStateAppend(begin, single, makeMarkovState([begin, single]))
        verifyMarkovStateAppend(begin, zero, begin)

        verifyMarkovStateAppend(end, begin, end)
        verifyMarkovStateAppend(end, end, end)
        verifyMarkovStateAppend(end, single, end)
        verifyMarkovStateAppend(end, zero, end)

        verifyMarkovStateAppend(single, begin, single)
        verifyMarkovStateAppend(single, end, makeMarkovState([single, end]))
        verifyMarkovStateAppend(single, .single("goober"), makeMarkovState([single, .single("goober")]))
        verifyMarkovStateAppend(single, zero, single)

        verifyMarkovStateAppend(zero, begin, begin)
        verifyMarkovStateAppend(zero, end, end)
        verifyMarkovStateAppend(zero, single, single)
        verifyMarkovStateAppend(zero, zero, zero)
    }

    @Test
    func canAppend_sequence() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let zero: Markov<String>.State = .zero
        let end: Markov<String>.State = .end
        let bilbo: Markov<String>.State = .single("bilbo")
        let frodo: Markov<String>.State = .single("frodo")
        let seq0: Markov<String>.State = makeMarkovState([])
        let seq1: Markov<String>.State = makeMarkovState([begin])
        let seq2: Markov<String>.State = makeMarkovState([begin, bilbo])
        let seq3: Markov<String>.State = makeMarkovState([begin, bilbo, frodo])
        let seq4: Markov<String>.State = makeMarkovState([begin, bilbo, frodo, end])

        #expect(!begin.canAppend(state: seq0))
        #expect(!begin.canAppend(state: seq1))
        #expect(!begin.canAppend(state: seq2))
        #expect(!begin.canAppend(state: seq3))
        #expect(!begin.canAppend(state: seq4))

        #expect(!end.canAppend(state: seq0))
        #expect(!end.canAppend(state: seq1))
        #expect(!end.canAppend(state: seq2))
        #expect(!end.canAppend(state: seq3))
        #expect(!end.canAppend(state: seq4))

        #expect(!single.canAppend(state: seq0))
        #expect(!single.canAppend(state: seq1))
        #expect(!single.canAppend(state: seq2))
        #expect(!single.canAppend(state: seq3))
        #expect(!single.canAppend(state: seq4))

        #expect(!zero.canAppend(state: seq0))
        #expect(!zero.canAppend(state: seq1))
        #expect(!zero.canAppend(state: seq2))
        #expect(!zero.canAppend(state: seq3))
        #expect(!zero.canAppend(state: seq4))

        #expect(!seq0.canAppend(state: begin))
        #expect(!seq1.canAppend(state: begin))
        #expect(!seq2.canAppend(state: begin))
        #expect(!seq3.canAppend(state: begin))
        #expect(!seq4.canAppend(state: begin))

        #expect(!seq0.canAppend(state: end))
        #expect(seq1.canAppend(state: end))
        #expect(seq2.canAppend(state: end))
        #expect(seq3.canAppend(state: end))
        #expect(!seq4.canAppend(state: end))

        #expect(!seq0.canAppend(state: single))
        #expect(seq1.canAppend(state: single))
        #expect(seq2.canAppend(state: single))
        #expect(seq3.canAppend(state: single))
        #expect(!seq4.canAppend(state: single))

        #expect(!seq0.canAppend(state: zero))
        #expect(!seq1.canAppend(state: zero))
        #expect(!seq2.canAppend(state: zero))
        #expect(!seq3.canAppend(state: zero))
        #expect(!seq4.canAppend(state: zero))

        #expect(!seq0.canAppend(state: seq0))
        #expect(!seq1.canAppend(state: seq0))
        #expect(!seq2.canAppend(state: seq0))
        #expect(!seq3.canAppend(state: seq0))
        #expect(!seq4.canAppend(state: seq0))

        #expect(!seq0.canAppend(state: seq1))
        #expect(!seq1.canAppend(state: seq1))
        #expect(!seq2.canAppend(state: seq1))
        #expect(!seq3.canAppend(state: seq1))
        #expect(!seq4.canAppend(state: seq1))

        #expect(!seq0.canAppend(state: seq2))
        #expect(!seq1.canAppend(state: seq2))
        #expect(!seq2.canAppend(state: seq2))
        #expect(!seq3.canAppend(state: seq2))
        #expect(!seq4.canAppend(state: seq2))

        #expect(!seq0.canAppend(state: seq3))
        #expect(!seq1.canAppend(state: seq3))
        #expect(!seq2.canAppend(state: seq3))
        #expect(!seq3.canAppend(state: seq3))
        #expect(!seq4.canAppend(state: seq3))

        #expect(!seq0.canAppend(state: seq4))
        #expect(!seq1.canAppend(state: seq4))
        #expect(!seq2.canAppend(state: seq4))
        #expect(!seq3.canAppend(state: seq4))
        #expect(!seq4.canAppend(state: seq4))
    }

    @Test
    func canAppend_simple() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let zero: Markov<String>.State = .zero
        let end: Markov<String>.State = .end

        #expect(!begin.canAppend(state: begin))
        #expect(begin.canAppend(state: end))
        #expect(begin.canAppend(state: single))
        #expect(!begin.canAppend(state: zero))

        #expect(!end.canAppend(state: begin))
        #expect(!end.canAppend(state: end))
        #expect(!end.canAppend(state: single))
        #expect(!end.canAppend(state: zero))

        #expect(!single.canAppend(state: begin))
        #expect(single.canAppend(state: end))
        #expect(single.canAppend(state: .single("goober")))
        #expect(!single.canAppend(state: zero))

        #expect(!zero.canAppend(state: begin))
        #expect(!zero.canAppend(state: end))
        #expect(zero.canAppend(state: single))
        #expect(!zero.canAppend(state: zero))
    }

    @Test
    func codable() throws {
        let cases: [Markov<Int>.State] = [
            .begin,
            .end,
            .zero,
            .single(42),
            makeMarkovState([.begin, .single(1), .single(2)])
        ]

        for state in cases {
            let data = try JSONEncoder().encode(state)
            let decoded = try JSONDecoder().decode(Markov<Int>.State.self, from: data)

            #expect(decoded == state)
        }
    }

    @Test
    func comparable() {
        let zero: Markov<Int>.State = .zero
        let begin: Markov<Int>.State = .begin
        let single0: Markov<Int>.State = .single(0)
        let single1: Markov<Int>.State = .single(1)
        let seq: Markov<Int>.State = makeMarkovState([.begin, .single(0)])
        let end: Markov<Int>.State = .end

        #expect(zero < begin)
        #expect(begin < single0)
        #expect(single0 < single1)
        #expect(single0 < seq)
        #expect(seq < end)
        #expect(zero < end)
        #expect(!(end < zero))
        #expect(!(single0 < zero))
    }

    @Test
    func hashable() {
        let states: Set<Markov<Int>.State> = [.begin, .end, .begin, .single(1), .single(1), .zero]

        #expect(states.count == 4)
    }

    @Test
    func hasNext_sequence() {
        let seq0: Markov<Int>.State = makeMarkovState([])
        let seq1: Markov<Int>.State = makeMarkovState([.begin])
        let seq2: Markov<Int>.State = makeMarkovState([.begin, .single(2_001)])
        let seq3: Markov<Int>.State = makeMarkovState([.begin, .single(2_001), .single(2_010)])
        let seq4: Markov<Int>.State = makeMarkovState([.begin, .single(2_001), .single(2_010), .end])

        #expect(!seq0.hasNext)
        #expect(seq1.hasNext)
        #expect(seq2.hasNext)
        #expect(seq3.hasNext)
        #expect(!seq4.hasNext)
    }

    @Test
    func hasNext_simple() {
        let single: Markov<Int>.State = .single(666)
        let begin: Markov<Int>.State = .begin
        let zero: Markov<Int>.State = .zero
        let end: Markov<Int>.State = .end

        #expect(begin.hasNext)
        #expect(!end.hasNext)
        #expect(single.hasNext)
        #expect(zero.hasNext)
    }
}
