// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct FallbackGeneratorTests {
}

// MARK: -

extension FallbackGeneratorTests {
    @Test
    func next_bothFail_returnsNil() throws {
        let empty1 = try #require(MarkovChain<String>(maximumOrder: 1))
        let empty2 = try #require(MarkovChain<String>(maximumOrder: 1))
        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: empty1, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: empty2, order: 1))

        var gen = FallbackGenerator(primary: p, secondary: s, committing: false)

        #expect(gen.next(after: []) == nil)
    }

    @Test
    func next_committing_latchesOnFirstMiss() throws {
        let chainA = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary has no distribution at all.
        let chainB = try #require(MarkovChain<String>(maximumOrder: 1))

        chainB.analyzer().analyze(sequence: ["x", "y", "z"])

        var p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainA, order: 1))

        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainB, order: 1))

        // Primary has no .begin distribution, so it misses on the first call.
        // With committing: true, all subsequent calls use secondary.
        var gen = FallbackGenerator(primary: p, secondary: s, committing: true)

        let first = gen.next(after: [])    // miss → secondary ("x"), latch
        let second = gen.next(after: ["x"])  // committed → secondary ("y")
        let third = gen.next(after: ["x", "y"]) // committed → secondary ("z")

        #expect(first == "x")
        #expect(second == "y")
        #expect(third == "z")

        // Verify primary is not used after latch by checking p's state is unchanged.
        #expect(p.next(after: []) == nil)  // primary still has no .begin
    }

    @Test
    func next_primarySucceeds() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        chainP.analyzer().analyze(sequence: ["a", "b", "c"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))

        var gen = FallbackGenerator(primary: p, secondary: s, committing: false)

        #expect(gen.next(after: []) == "a")
    }

    @Test
    func next_secondaryUsed_whenPrimaryFails() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary has no .begin distribution.

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))

        var gen = FallbackGenerator(primary: p, secondary: s, committing: false)

        #expect(gen.next(after: []) == "x")
    }

    @Test
    func next_terminal_firesFallback() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary: begin → "a" → .end (terminal after "a")
        chainP.analyzer().analyze(sequence: ["a"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        // Secondary: begin → "x"
        chainS.analyzer().analyze(sequence: ["x"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))

        var gen = FallbackGenerator(primary: p, secondary: s, committing: false)

        // Primary produces "a" then terminates (nil). Fallback produces "x".
        #expect(gen.next(after: []) == "a")
        #expect(gen.next(after: ["a"]) == "x")  // primary returns nil; secondary used
    }

    @Test
    func next_transient_resumesPrimary() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary knows: "b" → "c"
        chainP.analyzer().analyze(sequence: ["b", "c"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        // Secondary knows: begin → "b"
        chainS.analyzer().analyze(sequence: ["b", "c"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))

        var gen = FallbackGenerator(primary: p, secondary: s, committing: false)

        // Step 1: primary has no .begin entry → secondary gives "b"
        let step1 = gen.next(after: [])

        #expect(step1 == "b")

        // Step 2: history is ["b"]; primary knows "b" → "c" → primary takes over
        let step2 = gen.next(after: ["b"])

        #expect(step2 == "c")
    }

    @Test
    func weights_committedToSecondary() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))
        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))

        var gen = FallbackGenerator(primary: p, secondary: s, committing: true)

        // Trigger the latch via next().
        _ = gen.next(after: [])

        // weights() should now return secondary's distribution.
        let weights = gen.weights(after: .begin)

        #expect(weights.map(\.target).contains(.state("x")))
    }

    @Test
    func weights_primaryAvailable() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        chainP.analyzer().analyze(sequence: ["a", "b"])

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))
        let gen = FallbackGenerator(primary: p, secondary: s, committing: false)
        let weights = gen.weights(after: .begin)

        #expect(weights.map(\.target).contains(.state("a")))
        #expect(!weights.map(\.target).contains(.state("x")))
    }

    @Test
    func weights_primaryUnavailable() throws {
        let chainP = try #require(MarkovChain<String>(maximumOrder: 1))

        // Primary has no .begin distribution.

        let chainS = try #require(MarkovChain<String>(maximumOrder: 1))

        chainS.analyzer().analyze(sequence: ["x"])

        let p: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainP, order: 1))
        let s: any MarkovChain<String>.Generator = try #require(SimpleGenerator(markovChain: chainS, order: 1))
        let gen = FallbackGenerator(primary: p, secondary: s, committing: false)
        let weights = gen.weights(after: .begin)

        #expect(weights.map(\.target).contains(.state("x")))
    }
}
