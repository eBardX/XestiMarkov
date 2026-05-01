// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainTransitionTargetTests {
}

// MARK: -

extension MarkovChainTransitionTargetTests {
    @Test
    func equality() {
        #expect(MarkovChain<String>.Transition.Target.end == .end)
        #expect(MarkovChain<String>.Transition.Target.state("a") == .state("a"))
    }

    @Test
    func inequality() {
        let end = MarkovChain<String>.Transition.Target.end
        let state1 = MarkovChain<String>.Transition.Target.state("a")
        let state2 = MarkovChain<String>.Transition.Target.state("b")

        #expect(end != state1)
        #expect(state1 != state2)
    }
}
