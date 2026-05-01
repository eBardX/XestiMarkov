// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainTransitionTests {
}

// MARK: -

extension MarkovChainTransitionTests {
    @Test
    func equality() {
        let a = MarkovChain<String>.Transition(source: .zero, target: .state("a"), weight: 1)
        let b = MarkovChain<String>.Transition(source: .zero, target: .state("a"), weight: 1)

        #expect(a == b)
    }

    @Test
    func inequality_source() {
        let a = MarkovChain<String>.Transition(source: .zero, target: .state("a"), weight: 1)
        let b = MarkovChain<String>.Transition(source: .begin, target: .state("a"), weight: 1)

        #expect(a != b)
    }

    @Test
    func inequality_target() {
        let a = MarkovChain<String>.Transition(source: .zero, target: .state("a"), weight: 1)
        let b = MarkovChain<String>.Transition(source: .zero, target: .end, weight: 1)

        #expect(a != b)
    }

    @Test
    func inequality_weight() {
        let a = MarkovChain<String>.Transition(source: .zero, target: .state("a"), weight: 1)
        let b = MarkovChain<String>.Transition(source: .zero, target: .state("a"), weight: 2)

        #expect(a != b)
    }

    @Test
    func source() {
        let transition = MarkovChain<String>.Transition(source: .begin,
                                                        target: .end,
                                                        weight: 0)

        #expect(transition.source == .begin)
    }

    @Test
    func target() {
        let transition = MarkovChain<String>.Transition(source: .begin,
                                                        target: .end,
                                                        weight: 0)

        #expect(transition.target == .end)
    }

    @Test
    func weight() {
        let transition = MarkovChain<String>.Transition(source: .begin,
                                                        target: .end,
                                                        weight: 42)

        #expect(transition.weight == 42)
    }
}
