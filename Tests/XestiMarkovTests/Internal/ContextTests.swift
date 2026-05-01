// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct ContextTests {
}

// MARK: -

extension ContextTests {
    @Test
    func append_limit() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let end: Context<String> = .end
        let bilbo: Context<String> = .single("bilbo")
        let frodo: Context<String> = .single("frodo")
        let seq2: Context<String> = makeContext([begin, bilbo])
        let seq3: Context<String> = makeContext([begin, bilbo, frodo])
        let seq4: Context<String> = makeContext([begin, bilbo, frodo, end])

        verifyContextAppend(seq3, end, end, limit: 1)
        verifyContextAppend(seq3, single, single, limit: 1)
        verifyContextAppend(seq2, begin, bilbo, limit: 1)
        verifyContextAppend(seq2, end, end, limit: 1)
        verifyContextAppend(seq2, single, single, limit: 1)
        verifyContextAppend(begin, end, end, limit: 1)
        verifyContextAppend(begin, single, single, limit: 1)
        verifyContextAppend(single, end, end, limit: 1)

        verifyContextAppend(seq3, end, makeContext([frodo, end]), limit: 2)
        verifyContextAppend(seq3, single, makeContext([frodo, single]), limit: 2)
        verifyContextAppend(seq2, begin, makeContext([begin, bilbo]), limit: 2)
        verifyContextAppend(seq2, end, makeContext([bilbo, end]), limit: 2)
        verifyContextAppend(seq2, single, makeContext([bilbo, single]), limit: 2)
        verifyContextAppend(begin, end, makeContext([begin, end]), limit: 2)
        verifyContextAppend(begin, single, makeContext([begin, single]), limit: 2)
        verifyContextAppend(single, end, makeContext([single, end]), limit: 2)

        verifyContextAppend(seq3, end, makeContext([bilbo, frodo, end]), limit: 3)
        verifyContextAppend(seq3, single, makeContext([bilbo, frodo, single]), limit: 3)
        verifyContextAppend(seq2, begin, makeContext([begin, bilbo]), limit: 3)
        verifyContextAppend(seq2, end, makeContext([begin, bilbo, end]), limit: 3)
        verifyContextAppend(seq2, single, makeContext([begin, bilbo, single]), limit: 3)
        verifyContextAppend(begin, end, makeContext([begin, end]), limit: 3)
        verifyContextAppend(begin, single, makeContext([begin, single]), limit: 3)
        verifyContextAppend(single, end, makeContext([single, end]), limit: 3)

        verifyContextAppend(seq3, end, seq4, limit: 4)
        verifyContextAppend(seq3, single, makeContext([begin, bilbo, frodo, single]), limit: 4)
        verifyContextAppend(seq2, begin, makeContext([begin, bilbo]), limit: 4)
        verifyContextAppend(seq2, end, makeContext([begin, bilbo, end]), limit: 4)
        verifyContextAppend(seq2, single, makeContext([begin, bilbo, single]), limit: 4)
        verifyContextAppend(begin, end, makeContext([begin, end]), limit: 4)
        verifyContextAppend(begin, single, makeContext([begin, single]), limit: 4)
        verifyContextAppend(single, end, makeContext([single, end]), limit: 4)

        verifyContextAppend(seq3, end, makeContext([begin, bilbo, frodo, end]), limit: 5)
        verifyContextAppend(seq3, single, makeContext([begin, bilbo, frodo, single]), limit: 5)
        verifyContextAppend(seq2, begin, makeContext([begin, bilbo]), limit: 5)
        verifyContextAppend(seq2, end, makeContext([begin, bilbo, end]), limit: 5)
        verifyContextAppend(seq2, single, makeContext([begin, bilbo, single]), limit: 5)
        verifyContextAppend(begin, end, makeContext([begin, end]), limit: 5)
        verifyContextAppend(begin, single, makeContext([begin, single]), limit: 5)
        verifyContextAppend(single, end, makeContext([single, end]), limit: 5)
    }

    @Test
    func append_sequence() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let zero: Context<String> = .zero
        let end: Context<String> = .end
        let bilbo: Context<String> = .single("bilbo")
        let frodo: Context<String> = .single("frodo")
        let seq0: Context<String> = makeContext([])
        let seq1: Context<String> = makeContext([begin])
        let seq2: Context<String> = makeContext([begin, bilbo])
        let seq3: Context<String> = makeContext([begin, bilbo, frodo])
        let seq4: Context<String> = makeContext([begin, bilbo, frodo, end])

        verifyContextAppend(begin, seq0, begin)
        verifyContextAppend(begin, seq1, begin)
        verifyContextAppend(begin, seq2, begin)
        verifyContextAppend(begin, seq3, begin)
        verifyContextAppend(begin, seq4, begin)

        verifyContextAppend(end, seq0, end)
        verifyContextAppend(end, seq1, end)
        verifyContextAppend(end, seq2, end)
        verifyContextAppend(end, seq3, end)
        verifyContextAppend(end, seq4, end)

        verifyContextAppend(single, seq0, single)
        verifyContextAppend(single, seq1, single)
        verifyContextAppend(single, seq2, single)
        verifyContextAppend(single, seq3, single)
        verifyContextAppend(single, seq4, single)

        verifyContextAppend(zero, seq0, zero)
        verifyContextAppend(zero, seq1, zero)
        verifyContextAppend(zero, seq2, zero)
        verifyContextAppend(zero, seq3, zero)
        verifyContextAppend(zero, seq4, zero)

        verifyContextAppend(seq0, begin, begin)
        verifyContextAppend(seq1, begin, begin)
        verifyContextAppend(seq2, begin, seq2)
        verifyContextAppend(seq3, begin, seq3)
        verifyContextAppend(seq4, begin, seq4)

        verifyContextAppend(seq0, end, end)
        verifyContextAppend(seq1, end, makeContext([begin, end]))
        verifyContextAppend(seq2, end, makeContext([begin, bilbo, end]))
        verifyContextAppend(seq3, end, makeContext([begin, bilbo, frodo, end]))
        verifyContextAppend(seq4, end, seq4)

        verifyContextAppend(seq0, single, single)
        verifyContextAppend(seq1, single, makeContext([begin, single]))
        verifyContextAppend(seq2, single, makeContext([begin, bilbo, single]))
        verifyContextAppend(seq3, single, makeContext([begin, bilbo, frodo, single]))
        verifyContextAppend(seq4, single, seq4)

        verifyContextAppend(seq0, zero, zero)
        verifyContextAppend(seq1, zero, begin)
        verifyContextAppend(seq2, zero, seq2)
        verifyContextAppend(seq3, zero, seq3)
        verifyContextAppend(seq4, zero, seq4)

        verifyContextAppend(seq0, seq0, zero)
        verifyContextAppend(seq1, seq0, begin)
        verifyContextAppend(seq2, seq0, seq2)
        verifyContextAppend(seq3, seq0, seq3)
        verifyContextAppend(seq4, seq0, seq4)

        verifyContextAppend(seq0, seq1, zero)
        verifyContextAppend(seq1, seq1, begin)
        verifyContextAppend(seq2, seq1, seq2)
        verifyContextAppend(seq3, seq1, seq3)
        verifyContextAppend(seq4, seq1, seq4)

        verifyContextAppend(seq0, seq2, zero)
        verifyContextAppend(seq1, seq2, begin)
        verifyContextAppend(seq2, seq2, seq2)
        verifyContextAppend(seq3, seq2, seq3)
        verifyContextAppend(seq4, seq2, seq4)

        verifyContextAppend(seq0, seq3, zero)
        verifyContextAppend(seq1, seq3, begin)
        verifyContextAppend(seq2, seq3, seq2)
        verifyContextAppend(seq3, seq3, seq3)
        verifyContextAppend(seq4, seq3, seq4)

        verifyContextAppend(seq0, seq4, zero)
        verifyContextAppend(seq1, seq4, begin)
        verifyContextAppend(seq2, seq4, seq2)
        verifyContextAppend(seq3, seq4, seq3)
        verifyContextAppend(seq4, seq4, seq4)
    }

    @Test
    func append_simple() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let zero: Context<String> = .zero
        let end: Context<String> = .end

        verifyContextAppend(begin, begin, begin)
        verifyContextAppend(begin, end, makeContext([begin, end]))
        verifyContextAppend(begin, single, makeContext([begin, single]))
        verifyContextAppend(begin, zero, begin)

        verifyContextAppend(end, begin, end)
        verifyContextAppend(end, end, end)
        verifyContextAppend(end, single, end)
        verifyContextAppend(end, zero, end)

        verifyContextAppend(single, begin, single)
        verifyContextAppend(single, end, makeContext([single, end]))
        verifyContextAppend(single, .single("goober"), makeContext([single, .single("goober")]))
        verifyContextAppend(single, zero, single)

        verifyContextAppend(zero, begin, begin)
        verifyContextAppend(zero, end, end)
        verifyContextAppend(zero, single, single)
        verifyContextAppend(zero, zero, zero)
    }

    @Test
    func canAppend_sequence() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let zero: Context<String> = .zero
        let end: Context<String> = .end
        let bilbo: Context<String> = .single("bilbo")
        let frodo: Context<String> = .single("frodo")
        let seq0: Context<String> = makeContext([])
        let seq1: Context<String> = makeContext([begin])
        let seq2: Context<String> = makeContext([begin, bilbo])
        let seq3: Context<String> = makeContext([begin, bilbo, frodo])
        let seq4: Context<String> = makeContext([begin, bilbo, frodo, end])

        #expect(!begin.canAppend(context: seq0))
        #expect(!begin.canAppend(context: seq1))
        #expect(!begin.canAppend(context: seq2))
        #expect(!begin.canAppend(context: seq3))
        #expect(!begin.canAppend(context: seq4))

        #expect(!end.canAppend(context: seq0))
        #expect(!end.canAppend(context: seq1))
        #expect(!end.canAppend(context: seq2))
        #expect(!end.canAppend(context: seq3))
        #expect(!end.canAppend(context: seq4))

        #expect(!single.canAppend(context: seq0))
        #expect(!single.canAppend(context: seq1))
        #expect(!single.canAppend(context: seq2))
        #expect(!single.canAppend(context: seq3))
        #expect(!single.canAppend(context: seq4))

        #expect(!zero.canAppend(context: seq0))
        #expect(!zero.canAppend(context: seq1))
        #expect(!zero.canAppend(context: seq2))
        #expect(!zero.canAppend(context: seq3))
        #expect(!zero.canAppend(context: seq4))

        #expect(!seq0.canAppend(context: begin))
        #expect(!seq1.canAppend(context: begin))
        #expect(!seq2.canAppend(context: begin))
        #expect(!seq3.canAppend(context: begin))
        #expect(!seq4.canAppend(context: begin))

        #expect(!seq0.canAppend(context: end))
        #expect(seq1.canAppend(context: end))
        #expect(seq2.canAppend(context: end))
        #expect(seq3.canAppend(context: end))
        #expect(!seq4.canAppend(context: end))

        #expect(!seq0.canAppend(context: single))
        #expect(seq1.canAppend(context: single))
        #expect(seq2.canAppend(context: single))
        #expect(seq3.canAppend(context: single))
        #expect(!seq4.canAppend(context: single))

        #expect(!seq0.canAppend(context: zero))
        #expect(!seq1.canAppend(context: zero))
        #expect(!seq2.canAppend(context: zero))
        #expect(!seq3.canAppend(context: zero))
        #expect(!seq4.canAppend(context: zero))

        #expect(!seq0.canAppend(context: seq0))
        #expect(!seq1.canAppend(context: seq0))
        #expect(!seq2.canAppend(context: seq0))
        #expect(!seq3.canAppend(context: seq0))
        #expect(!seq4.canAppend(context: seq0))

        #expect(!seq0.canAppend(context: seq1))
        #expect(!seq1.canAppend(context: seq1))
        #expect(!seq2.canAppend(context: seq1))
        #expect(!seq3.canAppend(context: seq1))
        #expect(!seq4.canAppend(context: seq1))

        #expect(!seq0.canAppend(context: seq2))
        #expect(!seq1.canAppend(context: seq2))
        #expect(!seq2.canAppend(context: seq2))
        #expect(!seq3.canAppend(context: seq2))
        #expect(!seq4.canAppend(context: seq2))

        #expect(!seq0.canAppend(context: seq3))
        #expect(!seq1.canAppend(context: seq3))
        #expect(!seq2.canAppend(context: seq3))
        #expect(!seq3.canAppend(context: seq3))
        #expect(!seq4.canAppend(context: seq3))

        #expect(!seq0.canAppend(context: seq4))
        #expect(!seq1.canAppend(context: seq4))
        #expect(!seq2.canAppend(context: seq4))
        #expect(!seq3.canAppend(context: seq4))
        #expect(!seq4.canAppend(context: seq4))
    }

    @Test
    func canAppend_simple() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let zero: Context<String> = .zero
        let end: Context<String> = .end

        #expect(!begin.canAppend(context: begin))
        #expect(begin.canAppend(context: end))
        #expect(begin.canAppend(context: single))
        #expect(!begin.canAppend(context: zero))

        #expect(!end.canAppend(context: begin))
        #expect(!end.canAppend(context: end))
        #expect(!end.canAppend(context: single))
        #expect(!end.canAppend(context: zero))

        #expect(!single.canAppend(context: begin))
        #expect(single.canAppend(context: end))
        #expect(single.canAppend(context: .single("goober")))
        #expect(!single.canAppend(context: zero))

        #expect(!zero.canAppend(context: begin))
        #expect(!zero.canAppend(context: end))
        #expect(zero.canAppend(context: single))
        #expect(!zero.canAppend(context: zero))
    }

    @Test
    func codable() throws {
        let cases: [Context<Int>] = [
            .begin,
            .end,
            .zero,
            .single(42),
            makeContext([.begin, .single(1), .single(2)])
        ]

        for context in cases {
            let data = try JSONEncoder().encode(context)
            let decoded = try JSONDecoder().decode(Context<Int>.self, from: data)

            #expect(decoded == context)
        }
    }

    @Test
    func comparable() {
        let zero: Context<Int> = .zero
        let begin: Context<Int> = .begin
        let single0: Context<Int> = .single(0)
        let single1: Context<Int> = .single(1)
        let seq: Context<Int> = makeContext([.begin, .single(0)])
        let end: Context<Int> = .end

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
        let contexts: Set<Context<Int>> = [.begin, .end, .begin, .single(1), .single(1), .zero]

        #expect(contexts.count == 4)
    }

    @Test
    func hasNext_sequence() {
        let seq0: Context<Int> = makeContext([])
        let seq1: Context<Int> = makeContext([.begin])
        let seq2: Context<Int> = makeContext([.begin, .single(2_001)])
        let seq3: Context<Int> = makeContext([.begin, .single(2_001), .single(2_010)])
        let seq4: Context<Int> = makeContext([.begin, .single(2_001), .single(2_010), .end])

        #expect(!seq0.hasNext)
        #expect(seq1.hasNext)
        #expect(seq2.hasNext)
        #expect(seq3.hasNext)
        #expect(!seq4.hasNext)
    }

    @Test
    func hasNext_simple() {
        let single: Context<Int> = .single(666)
        let begin: Context<Int> = .begin
        let zero: Context<Int> = .zero
        let end: Context<Int> = .end

        #expect(begin.hasNext)
        #expect(!end.hasNext)
        #expect(single.hasNext)
        #expect(zero.hasNext)
    }
}
