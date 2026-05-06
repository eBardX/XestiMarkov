// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainStatisticsTests {
}

// MARK: -

extension MarkovChainStatisticsTests {
    @Test
    func statistics_aboveRange_returnsNil() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.statistics(forOrder: 2) == nil)
    }

    @Test
    func statistics_belowRange_returnsNil() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.statistics(forOrder: -1) == nil)
    }

    @Test
    func statistics_distinctStates_afterTraining() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.distinctStates == 3)
    }

    @Test
    func statistics_distinctStates_emptyChain() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.distinctStates == 0)
    }

    @Test
    func statistics_distinctStates_sameAcrossOrders() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats0 = try #require(markovChain.statistics(forOrder: 0))
        let stats1 = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats0.distinctStates == stats1.distinctStates)
    }

    @Test
    func statistics_emptyChain_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let stats = try #require(markovChain.statistics(forOrder: 0))

        #expect(stats.distinctPredecessors == 0)
        #expect(stats.totalTransitions == 0)
        #expect(stats.meanTransitions == 0.0)
        #expect(stats.minimumTransitions == 0)
        #expect(stats.maximumTransitions == 0)
        #expect(stats.branchingRatio == 0.0)
    }

    @Test
    func statistics_emptyChain_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.distinctPredecessors == 0)
        #expect(stats.totalTransitions == 0)
        #expect(stats.meanTransitions == 0.0)
        #expect(stats.minimumTransitions == 0)
        #expect(stats.maximumTransitions == 0)
        #expect(stats.branchingRatio == 0.0)
    }

    @Test
    func statistics_order0_distinctPredecessors_alwaysZero() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 0))

        #expect(stats.distinctPredecessors == 0)
    }

    @Test
    func statistics_order0_totalTransitions() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        // Sequence B: a appears twice, b once, c once → 4 zeroth-order transitions
        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 0))

        #expect(stats.totalTransitions == 4)
    }

    @Test
    func statistics_order1_branchingRatio_noBranching() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        // Sequence A: every predecessor leads to exactly one successor
        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.branchingRatio == 0.0)
    }

    @Test
    func statistics_order1_branchingRatio_partial() throws {
        let expected = 1.0 / 4.0
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        // Only .single("a") branches (→ "b" and → "c"); 1 out of 4 predecessors
        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(abs(stats.branchingRatio - expected) < 1e-9)
    }

    @Test
    func statistics_order1_distinctPredecessors() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.distinctPredecessors == 4)
    }

    @Test
    func statistics_order1_maximumTransitions() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        // .single("a") sees both "b" and "c" as successors: total weight 2
        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.maximumTransitions == 2)
    }

    @Test
    func statistics_order1_meanTransitions() throws {
        let expected = 5.0 / 4.0
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(abs(stats.meanTransitions - expected) < 1e-9)
    }

    @Test
    func statistics_order1_minimumTransitions() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.minimumTransitions == 1)
    }

    @Test
    func statistics_order1_totalTransitions() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.totalTransitions == 5)
    }

    @Test
    func statistics_order2_distinctPredecessors() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        let stats = try #require(markovChain.statistics(forOrder: 2))

        #expect(stats.distinctPredecessors == 3)
    }

    @Test
    func statistics_order_isCorrect() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        let stats = try #require(markovChain.statistics(forOrder: 1))

        #expect(stats.order == 1)
    }
}
