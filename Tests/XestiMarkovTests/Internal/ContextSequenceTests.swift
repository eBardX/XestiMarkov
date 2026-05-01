// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct ContextSequenceTests {
}

// MARK: -

extension ContextSequenceTests {
    @Test
    func append_limit() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let end: Context<String> = .end
        let bilbo: Context<String> = .single("bilbo")
        let frodo: Context<String> = .single("frodo")

        verifyContextSequenceAppend([begin, bilbo, frodo], end, [end], limit: 1)
        verifyContextSequenceAppend([begin, bilbo, frodo], single, [single], limit: 1)
        verifyContextSequenceAppend([begin, bilbo], begin, [bilbo], limit: 1)
        verifyContextSequenceAppend([begin, bilbo], end, [end], limit: 1)
        verifyContextSequenceAppend([begin, bilbo], single, [single], limit: 1)
        verifyContextSequenceAppend([begin], end, [end], limit: 1)
        verifyContextSequenceAppend([begin], single, [single], limit: 1)
        verifyContextSequenceAppend([single], end, [end], limit: 1)

        verifyContextSequenceAppend([begin, bilbo, frodo], end, [frodo, end], limit: 2)
        verifyContextSequenceAppend([begin, bilbo, frodo], single, [frodo, single], limit: 2)
        verifyContextSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 2)
        verifyContextSequenceAppend([begin, bilbo], end, [bilbo, end], limit: 2)
        verifyContextSequenceAppend([begin, bilbo], single, [bilbo, single], limit: 2)
        verifyContextSequenceAppend([begin], end, [begin, end], limit: 2)
        verifyContextSequenceAppend([begin], single, [begin, single], limit: 2)
        verifyContextSequenceAppend([single], end, [single, end], limit: 2)

        verifyContextSequenceAppend([begin, bilbo, frodo], end, [bilbo, frodo, end], limit: 3)
        verifyContextSequenceAppend([begin, bilbo, frodo], single, [bilbo, frodo, single], limit: 3)
        verifyContextSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 3)
        verifyContextSequenceAppend([begin, bilbo], end, [begin, bilbo, end], limit: 3)
        verifyContextSequenceAppend([begin, bilbo], single, [begin, bilbo, single], limit: 3)
        verifyContextSequenceAppend([begin], end, [begin, end], limit: 3)
        verifyContextSequenceAppend([begin], single, [begin, single], limit: 3)
        verifyContextSequenceAppend([single], end, [single, end], limit: 3)

        verifyContextSequenceAppend([begin, bilbo, frodo], end, [begin, bilbo, frodo, end], limit: 4)
        verifyContextSequenceAppend([begin, bilbo, frodo], single, [begin, bilbo, frodo, single], limit: 4)
        verifyContextSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 4)
        verifyContextSequenceAppend([begin, bilbo], end, [begin, bilbo, end], limit: 4)
        verifyContextSequenceAppend([begin, bilbo], single, [begin, bilbo, single], limit: 4)
        verifyContextSequenceAppend([begin], end, [begin, end], limit: 4)
        verifyContextSequenceAppend([begin], single, [begin, single], limit: 4)
        verifyContextSequenceAppend([single], end, [single, end], limit: 4)

        verifyContextSequenceAppend([begin, bilbo, frodo], end, [begin, bilbo, frodo, end], limit: 5)
        verifyContextSequenceAppend([begin, bilbo, frodo], single, [begin, bilbo, frodo, single], limit: 5)
        verifyContextSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 5)
        verifyContextSequenceAppend([begin, bilbo], end, [begin, bilbo, end], limit: 5)
        verifyContextSequenceAppend([begin, bilbo], single, [begin, bilbo, single], limit: 5)
        verifyContextSequenceAppend([begin], end, [begin, end], limit: 5)
        verifyContextSequenceAppend([begin], single, [begin, single], limit: 5)
        verifyContextSequenceAppend([single], end, [single, end], limit: 5)
    }

    @Test
    func append_sequence() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let zero: Context<String> = .zero
        let end: Context<String> = .end
        let bilbo: Context<String> = .single("bilbo")
        let frodo: Context<String> = .single("frodo")
        let seq0: Context<String> = .sequence(makeContextSequence([]))
        let seq1: Context<String> = .sequence(makeContextSequence([begin]))
        let seq2: Context<String> = .sequence(makeContextSequence([begin, bilbo]))
        let seq3: Context<String> = .sequence(makeContextSequence([begin, bilbo, frodo]))
        let seq4: Context<String> = .sequence(makeContextSequence([begin, bilbo, frodo, end]))

        verifyContextSequenceAppend([begin], seq0, [begin])
        verifyContextSequenceAppend([begin], seq1, [begin])
        verifyContextSequenceAppend([begin], seq2, [begin])
        verifyContextSequenceAppend([begin], seq3, [begin])
        verifyContextSequenceAppend([begin], seq4, [begin])

        verifyContextSequenceAppend([end], seq0, [end])
        verifyContextSequenceAppend([end], seq1, [end])
        verifyContextSequenceAppend([end], seq2, [end])
        verifyContextSequenceAppend([end], seq3, [end])
        verifyContextSequenceAppend([end], seq4, [end])

        verifyContextSequenceAppend([single], seq0, [single])
        verifyContextSequenceAppend([single], seq1, [single])
        verifyContextSequenceAppend([single], seq2, [single])
        verifyContextSequenceAppend([single], seq3, [single])
        verifyContextSequenceAppend([single], seq4, [single])

        verifyContextSequenceAppend([zero], seq0, [])
        verifyContextSequenceAppend([zero], seq1, [])
        verifyContextSequenceAppend([zero], seq2, [])
        verifyContextSequenceAppend([zero], seq3, [])
        verifyContextSequenceAppend([zero], seq4, [])

        verifyContextSequenceAppend([], begin, [begin])
        verifyContextSequenceAppend([begin], begin, [begin])
        verifyContextSequenceAppend([begin, bilbo], begin, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], begin, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], begin, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], end, [end])
        verifyContextSequenceAppend([begin], end, [begin, end])
        verifyContextSequenceAppend([begin, bilbo], end, [begin, bilbo, end])
        verifyContextSequenceAppend([begin, bilbo, frodo], end, [begin, bilbo, frodo, end])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], end, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], single, [single])
        verifyContextSequenceAppend([begin], single, [begin, single])
        verifyContextSequenceAppend([begin, bilbo], single, [begin, bilbo, single])
        verifyContextSequenceAppend([begin, bilbo, frodo], single, [begin, bilbo, frodo, single])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], single, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], zero, [])
        verifyContextSequenceAppend([begin], zero, [begin])
        verifyContextSequenceAppend([begin, bilbo], zero, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], zero, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], zero, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], seq0, [])
        verifyContextSequenceAppend([begin], seq0, [begin])
        verifyContextSequenceAppend([begin, bilbo], seq0, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], seq0, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], seq0, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], seq1, [])
        verifyContextSequenceAppend([begin], seq1, [begin])
        verifyContextSequenceAppend([begin, bilbo], seq1, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], seq1, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], seq1, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], seq2, [])
        verifyContextSequenceAppend([begin], seq2, [begin])
        verifyContextSequenceAppend([begin, bilbo], seq2, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], seq2, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], seq2, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], seq3, [])
        verifyContextSequenceAppend([begin], seq3, [begin])
        verifyContextSequenceAppend([begin, bilbo], seq3, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], seq3, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], seq3, [begin, bilbo, frodo, end])

        verifyContextSequenceAppend([], seq4, [])
        verifyContextSequenceAppend([begin], seq4, [begin])
        verifyContextSequenceAppend([begin, bilbo], seq4, [begin, bilbo])
        verifyContextSequenceAppend([begin, bilbo, frodo], seq4, [begin, bilbo, frodo])
        verifyContextSequenceAppend([begin, bilbo, frodo, end], seq4, [begin, bilbo, frodo, end])
    }

    @Test
    func append_simple() {
        let single: Context<String> = .single("fubar")
        let begin: Context<String> = .begin
        let zero: Context<String> = .zero
        let end: Context<String> = .end

        verifyContextSequenceAppend([begin], begin, [begin])
        verifyContextSequenceAppend([begin], end, [begin, end])
        verifyContextSequenceAppend([begin], single, [begin, single])
        verifyContextSequenceAppend([begin], zero, [begin])

        verifyContextSequenceAppend([end], begin, [end])
        verifyContextSequenceAppend([end], end, [end])
        verifyContextSequenceAppend([end], single, [end])
        verifyContextSequenceAppend([end], zero, [end])

        verifyContextSequenceAppend([single], begin, [single])
        verifyContextSequenceAppend([single], end, [single, end])
        verifyContextSequenceAppend([single], .single("goober"), [single, .single("goober")])
        verifyContextSequenceAppend([single], zero, [single])

        verifyContextSequenceAppend([zero], begin, [begin])
        verifyContextSequenceAppend([zero], end, [end])
        verifyContextSequenceAppend([zero], single, [single])
        verifyContextSequenceAppend([zero], zero, [])
    }

    @Test
    func codable() throws {
        let seq = makeContextSequence([.begin, .single(1), .single(2)] as [Context<Int>])
        let data = try JSONEncoder().encode(seq)
        let decoded = try JSONDecoder().decode(ContextSequence<Int>.self, from: data)

        #expect(decoded == seq)
    }

    @Test
    func comparable() {
        let a = makeContextSequence([.begin, .single(1)] as [Context<Int>])
        let b = makeContextSequence([.begin, .single(2)] as [Context<Int>])

        #expect(a < b)
        #expect(!(b < a))
        #expect(!(a < a))   // swiftlint:disable:this identical_operands
    }

    @Test
    func count() {
        let context1: Context<Int> = .single(666)
        let context2: Context<Int> = .single(42)

        var seq = ContextSequence<Int>()

        seq.append(context: context1, limit: 100)
        seq.append(context: context2, limit: 100)

        #expect(seq.count == 2)
    }

    @Test
    func hashable() {
        let a = makeContextSequence([.begin, .single(1)] as [Context<Int>])
        let b = makeContextSequence([.begin, .single(2)] as [Context<Int>])

        let set: Set<ContextSequence<Int>> = [a, b, a]

        #expect(set.count == 2)
    }

    @Test
    func `init`() {
        let seq = ContextSequence<Int>()

        #expect(seq.count == 0)     // swiftlint:disable:this empty_count
        #expect(seq.last == nil)
    }

    @Test
    func last() {
        let context1: Context<Int> = .single(666)
        let context2: Context<Int> = .single(42)

        var seq = ContextSequence<Int>()

        seq.append(context: context1, limit: 100)
        seq.append(context: context2, limit: 100)

        #expect(seq.last == context2)
    }

    @Test
    func makeIterator() {
        let context1: Context<Int> = .single(666)
        let context2: Context<Int> = .single(42)
        let context3: Context<Int> = .single(2_001)

        var seq = ContextSequence<Int>()

        seq.append(context: context1, limit: 100)
        seq.append(context: context2, limit: 100)
        seq.append(context: context3, limit: 100)

        var itr = seq.makeIterator()

        #expect(itr.next() == context1)
        #expect(itr.next() == context2)
        #expect(itr.next() == context3)
        #expect(itr.next() == nil)
    }

    @Test
    func `subscript`() {
        let context1: Context<Int> = .single(666)
        let context2: Context<Int> = .single(42)
        let context3: Context<Int> = .single(2_001)

        var seq = ContextSequence<Int>()

        seq.append(context: context1, limit: 100)
        seq.append(context: context2, limit: 100)
        seq.append(context: context3, limit: 100)

        #expect(seq[0] == context1)
        #expect(seq[1] == context2)
        #expect(seq[2] == context3)
    }
}
