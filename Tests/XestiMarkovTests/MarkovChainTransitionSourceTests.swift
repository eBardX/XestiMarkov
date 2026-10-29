// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainTransitionSourceTests {
}

// MARK: -

extension MarkovChainTransitionSourceTests {
    @Test
    func beginStates_equality() {
        let anchored = MarkovChain<String>.Transition.Source.beginStates(["a"])

        #expect(anchored == .beginStates(["a"]))
        #expect(anchored != .states(["a"]))
        #expect(anchored != .begin)
    }

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

    @Test
    func order() {
        #expect(MarkovChain<String>.Transition.Source.zero.order == 0)
        #expect(MarkovChain<String>.Transition.Source.begin.order == 1)
        #expect(MarkovChain<String>.Transition.Source.states(["a"]).order == 1)
        #expect(MarkovChain<String>.Transition.Source.states(["a", "b"]).order == 2)
        #expect(MarkovChain<String>.Transition.Source.beginStates(["a"]).order == 2)
        #expect(MarkovChain<String>.Transition.Source.beginStates(["a", "b"]).order == 3)
    }
}
