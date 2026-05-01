// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainTransitionSourceTests {
}

// MARK: -

extension MarkovChainTransitionSourceTests {
    @Test
    func equality() {
        #expect(MarkovChain<String>.Transition.Source.begin == .begin)
        #expect(MarkovChain<String>.Transition.Source.states(["a"]) == .states(["a"]))
        #expect(MarkovChain<String>.Transition.Source.states(["a", "b"]) == .states(["a", "b"]))
        #expect(MarkovChain<String>.Transition.Source.zero == .zero)
    }

    @Test
    func inequality() {
        let begin = MarkovChain<String>.Transition.Source.begin
        let states1 = MarkovChain<String>.Transition.Source.states(["a"])
        let states2 = MarkovChain<String>.Transition.Source.states(["a", "b"])
        let zero = MarkovChain<String>.Transition.Source.zero

        #expect(begin != states1)
        #expect(begin != states2)
        #expect(begin != zero)
        #expect(states1 != states2)
        #expect(states1 != zero)
        #expect(states2 != zero)
    }
}
