// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import Testing
@testable import XestiMarkov

struct MarkovStateSequenceTests {
}

// MARK: -

extension MarkovStateSequenceTests {
    @Test
    func append_limit() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let end: Markov<String>.State = .end
        let bilbo: Markov<String>.State = .single("bilbo")
        let frodo: Markov<String>.State = .single("frodo")

        verifyStateSequenceAppend([begin, bilbo, frodo], end, [end], limit: 1)
        verifyStateSequenceAppend([begin, bilbo, frodo], single, [single], limit: 1)
        verifyStateSequenceAppend([begin, bilbo], begin, [bilbo], limit: 1)
        verifyStateSequenceAppend([begin, bilbo], end, [end], limit: 1)
        verifyStateSequenceAppend([begin, bilbo], single, [single], limit: 1)
        verifyStateSequenceAppend([begin], end, [end], limit: 1)
        verifyStateSequenceAppend([begin], single, [single], limit: 1)
        verifyStateSequenceAppend([single], end, [end], limit: 1)

        verifyStateSequenceAppend([begin, bilbo, frodo], end, [frodo, end], limit: 2)
        verifyStateSequenceAppend([begin, bilbo, frodo], single, [frodo, single], limit: 2)
        verifyStateSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 2)
        verifyStateSequenceAppend([begin, bilbo], end, [bilbo, end], limit: 2)
        verifyStateSequenceAppend([begin, bilbo], single, [bilbo, single], limit: 2)
        verifyStateSequenceAppend([begin], end, [begin, end], limit: 2)
        verifyStateSequenceAppend([begin], single, [begin, single], limit: 2)
        verifyStateSequenceAppend([single], end, [single, end], limit: 2)

        verifyStateSequenceAppend([begin, bilbo, frodo], end, [bilbo, frodo, end], limit: 3)
        verifyStateSequenceAppend([begin, bilbo, frodo], single, [bilbo, frodo, single], limit: 3)
        verifyStateSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 3)
        verifyStateSequenceAppend([begin, bilbo], end, [begin, bilbo, end], limit: 3)
        verifyStateSequenceAppend([begin, bilbo], single, [begin, bilbo, single], limit: 3)
        verifyStateSequenceAppend([begin], end, [begin, end], limit: 3)
        verifyStateSequenceAppend([begin], single, [begin, single], limit: 3)
        verifyStateSequenceAppend([single], end, [single, end], limit: 3)

        verifyStateSequenceAppend([begin, bilbo, frodo], end, [begin, bilbo, frodo, end], limit: 4)
        verifyStateSequenceAppend([begin, bilbo, frodo], single, [begin, bilbo, frodo, single], limit: 4)
        verifyStateSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 4)
        verifyStateSequenceAppend([begin, bilbo], end, [begin, bilbo, end], limit: 4)
        verifyStateSequenceAppend([begin, bilbo], single, [begin, bilbo, single], limit: 4)
        verifyStateSequenceAppend([begin], end, [begin, end], limit: 4)
        verifyStateSequenceAppend([begin], single, [begin, single], limit: 4)
        verifyStateSequenceAppend([single], end, [single, end], limit: 4)

        verifyStateSequenceAppend([begin, bilbo, frodo], end, [begin, bilbo, frodo, end], limit: 5)
        verifyStateSequenceAppend([begin, bilbo, frodo], single, [begin, bilbo, frodo, single], limit: 5)
        verifyStateSequenceAppend([begin, bilbo], begin, [begin, bilbo], limit: 5)
        verifyStateSequenceAppend([begin, bilbo], end, [begin, bilbo, end], limit: 5)
        verifyStateSequenceAppend([begin, bilbo], single, [begin, bilbo, single], limit: 5)
        verifyStateSequenceAppend([begin], end, [begin, end], limit: 5)
        verifyStateSequenceAppend([begin], single, [begin, single], limit: 5)
        verifyStateSequenceAppend([single], end, [single, end], limit: 5)
    }

    @Test
    func append_sequence() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let zero: Markov<String>.State = .zero
        let end: Markov<String>.State = .end
        let bilbo: Markov<String>.State = .single("bilbo")
        let frodo: Markov<String>.State = .single("frodo")
        let seq0: Markov<String>.State = .sequence(makeStateSequence([]))
        let seq1: Markov<String>.State = .sequence(makeStateSequence([begin]))
        let seq2: Markov<String>.State = .sequence(makeStateSequence([begin, bilbo]))
        let seq3: Markov<String>.State = .sequence(makeStateSequence([begin, bilbo, frodo]))
        let seq4: Markov<String>.State = .sequence(makeStateSequence([begin, bilbo, frodo, end]))

        verifyStateSequenceAppend([begin], seq0, [begin])
        verifyStateSequenceAppend([begin], seq1, [begin])
        verifyStateSequenceAppend([begin], seq2, [begin])
        verifyStateSequenceAppend([begin], seq3, [begin])
        verifyStateSequenceAppend([begin], seq4, [begin])

        verifyStateSequenceAppend([end], seq0, [end])
        verifyStateSequenceAppend([end], seq1, [end])
        verifyStateSequenceAppend([end], seq2, [end])
        verifyStateSequenceAppend([end], seq3, [end])
        verifyStateSequenceAppend([end], seq4, [end])

        verifyStateSequenceAppend([single], seq0, [single])
        verifyStateSequenceAppend([single], seq1, [single])
        verifyStateSequenceAppend([single], seq2, [single])
        verifyStateSequenceAppend([single], seq3, [single])
        verifyStateSequenceAppend([single], seq4, [single])

        verifyStateSequenceAppend([zero], seq0, [])
        verifyStateSequenceAppend([zero], seq1, [])
        verifyStateSequenceAppend([zero], seq2, [])
        verifyStateSequenceAppend([zero], seq3, [])
        verifyStateSequenceAppend([zero], seq4, [])

        verifyStateSequenceAppend([], begin, [begin])
        verifyStateSequenceAppend([begin], begin, [begin])
        verifyStateSequenceAppend([begin, bilbo], begin, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], begin, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], begin, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], end, [end])
        verifyStateSequenceAppend([begin], end, [begin, end])
        verifyStateSequenceAppend([begin, bilbo], end, [begin, bilbo, end])
        verifyStateSequenceAppend([begin, bilbo, frodo], end, [begin, bilbo, frodo, end])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], end, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], single, [single])
        verifyStateSequenceAppend([begin], single, [begin, single])
        verifyStateSequenceAppend([begin, bilbo], single, [begin, bilbo, single])
        verifyStateSequenceAppend([begin, bilbo, frodo], single, [begin, bilbo, frodo, single])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], single, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], zero, [])
        verifyStateSequenceAppend([begin], zero, [begin])
        verifyStateSequenceAppend([begin, bilbo], zero, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], zero, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], zero, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], seq0, [])
        verifyStateSequenceAppend([begin], seq0, [begin])
        verifyStateSequenceAppend([begin, bilbo], seq0, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], seq0, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], seq0, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], seq1, [])
        verifyStateSequenceAppend([begin], seq1, [begin])
        verifyStateSequenceAppend([begin, bilbo], seq1, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], seq1, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], seq1, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], seq2, [])
        verifyStateSequenceAppend([begin], seq2, [begin])
        verifyStateSequenceAppend([begin, bilbo], seq2, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], seq2, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], seq2, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], seq3, [])
        verifyStateSequenceAppend([begin], seq3, [begin])
        verifyStateSequenceAppend([begin, bilbo], seq3, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], seq3, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], seq3, [begin, bilbo, frodo, end])

        verifyStateSequenceAppend([], seq4, [])
        verifyStateSequenceAppend([begin], seq4, [begin])
        verifyStateSequenceAppend([begin, bilbo], seq4, [begin, bilbo])
        verifyStateSequenceAppend([begin, bilbo, frodo], seq4, [begin, bilbo, frodo])
        verifyStateSequenceAppend([begin, bilbo, frodo, end], seq4, [begin, bilbo, frodo, end])
    }

    @Test
    func append_simple() {
        let single: Markov<String>.State = .single("fubar")
        let begin: Markov<String>.State = .begin
        let zero: Markov<String>.State = .zero
        let end: Markov<String>.State = .end

        verifyStateSequenceAppend([begin], begin, [begin])
        verifyStateSequenceAppend([begin], end, [begin, end])
        verifyStateSequenceAppend([begin], single, [begin, single])
        verifyStateSequenceAppend([begin], zero, [begin])

        verifyStateSequenceAppend([end], begin, [end])
        verifyStateSequenceAppend([end], end, [end])
        verifyStateSequenceAppend([end], single, [end])
        verifyStateSequenceAppend([end], zero, [end])

        verifyStateSequenceAppend([single], begin, [single])
        verifyStateSequenceAppend([single], end, [single, end])
        verifyStateSequenceAppend([single], .single("goober"), [single, .single("goober")])
        verifyStateSequenceAppend([single], zero, [single])

        verifyStateSequenceAppend([zero], begin, [begin])
        verifyStateSequenceAppend([zero], end, [end])
        verifyStateSequenceAppend([zero], single, [single])
        verifyStateSequenceAppend([zero], zero, [])
    }

    @Test
    func codable() throws {
        let seq = makeStateSequence([.begin, .single(1), .single(2)] as [Markov<Int>.State])
        let data = try JSONEncoder().encode(seq)
        let decoded = try JSONDecoder().decode(Markov<Int>.StateSequence.self, from: data)

        #expect(decoded == seq)
    }

    @Test
    func comparable() {
        let a = makeStateSequence([.begin, .single(1)] as [Markov<Int>.State])
        let b = makeStateSequence([.begin, .single(2)] as [Markov<Int>.State])

        #expect(a < b)
        #expect(!(b < a))
        #expect(!(a < a))   // swiftlint:disable:this identical_operands
    }

    @Test
    func count() {
        let event1: Markov<Int>.State = .single(666)
        let event2: Markov<Int>.State = .single(42)

        var seq = Markov<Int>.StateSequence()

        seq.append(state: event1, limit: 100)
        seq.append(state: event2, limit: 100)

        #expect(seq.count == 2)
    }

    @Test
    func hashable() {
        let a = makeStateSequence([.begin, .single(1)] as [Markov<Int>.State])
        let b = makeStateSequence([.begin, .single(2)] as [Markov<Int>.State])

        let set: Set<Markov<Int>.StateSequence> = [a, b, a]

        #expect(set.count == 2)
    }

    @Test
    func `init`() {
        let seq = Markov<Int>.StateSequence()

        #expect(seq.count == 0)     // swiftlint:disable:this empty_count
        #expect(seq.last == nil)
    }

    @Test
    func last() {
        let event1: Markov<Int>.State = .single(666)
        let event2: Markov<Int>.State = .single(42)

        var seq = Markov<Int>.StateSequence()

        seq.append(state: event1, limit: 100)
        seq.append(state: event2, limit: 100)

        #expect(seq.last == event2)
    }

    @Test
    func makeIterator() {
        let event1: Markov<Int>.State = .single(666)
        let event2: Markov<Int>.State = .single(42)
        let event3: Markov<Int>.State = .single(2_001)

        var seq = Markov<Int>.StateSequence()

        seq.append(state: event1, limit: 100)
        seq.append(state: event2, limit: 100)
        seq.append(state: event3, limit: 100)

        var itr = seq.makeIterator()

        #expect(itr.next() == event1)
        #expect(itr.next() == event2)
        #expect(itr.next() == event3)
        #expect(itr.next() == nil)
    }

    @Test
    func `subscript`() {
        let event1: Markov<Int>.State = .single(666)
        let event2: Markov<Int>.State = .single(42)
        let event3: Markov<Int>.State = .single(2_001)

        var seq = Markov<Int>.StateSequence()

        seq.append(state: event1, limit: 100)
        seq.append(state: event2, limit: 100)
        seq.append(state: event3, limit: 100)

        #expect(seq[0] == event1)
        #expect(seq[1] == event2)
        #expect(seq[2] == event3)
    }
}
