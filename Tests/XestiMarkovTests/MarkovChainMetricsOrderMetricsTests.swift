// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainMetricsOrderMetricsTests {
}

// MARK: -

extension MarkovChainMetricsOrderMetricsTests {
    @Test
    func adequacyRatio_isNil_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[0].adequacyRatio == nil)
    }

    @Test
    func adequacyRatio_lessThanOne_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        let ratio = try #require(markovChain.metrics().orderMetrics[1].adequacyRatio)

        #expect(ratio >= 0.0)
        #expect(ratio < 1.0)
    }

    @Test
    func branchingRatio_noBranching_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        #expect(markovChain.metrics().orderMetrics[1].branchingRatio == 0.0)
    }

    @Test
    func branchingRatio_partial_order1() throws {
        let expected = 1.0 / 4.0
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(abs(markovChain.metrics().orderMetrics[1].branchingRatio - expected) < 1e-9)
    }

    @Test
    func distinctPredecessors_alwaysZero_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[0].distinctPredecessors == 0)
    }

    @Test
    func distinctPredecessors_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[1].distinctPredecessors == 4)
    }

    @Test
    func distinctPredecessors_order2() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        #expect(markovChain.metrics().orderMetrics[2].distinctPredecessors == 3)
    }

    @Test
    func emptyChain_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let om = markovChain.metrics().orderMetrics[0]

        #expect(om.adequacyRatio == nil)
        #expect(om.branchingRatio == 0.0)
        #expect(om.distinctPredecessors == 0)
        #expect(om.maximumTransitions == 0)
        #expect(om.meanTransitions == 0.0)
        #expect(om.minimumTransitions == 0)
        #expect(om.totalTransitions == 0)
    }

    @Test
    func emptyChain_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let om = markovChain.metrics().orderMetrics[1]

        #expect(om.adequacyRatio == nil)
        #expect(om.branchingRatio == 0.0)
        #expect(om.distinctPredecessors == 0)
        #expect(om.maximumTransitions == 0)
        #expect(om.meanTransitions == 0.0)
        #expect(om.minimumTransitions == 0)
        #expect(om.totalTransitions == 0)
    }

    @Test
    func maximumTransitions_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[1].maximumTransitions == 2)
    }

    @Test
    func meanTransitions_order1() throws {
        let expected = 5.0 / 4.0
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(abs(markovChain.metrics().orderMetrics[1].meanTransitions - expected) < 1e-9)
    }

    @Test
    func minimumTransitions_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[1].minimumTransitions == 1)
    }

    @Test
    func order_isCorrect_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.metrics().orderMetrics[0].order == 0)
    }

    @Test
    func order_isCorrect_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b"])

        #expect(markovChain.metrics().orderMetrics[1].order == 1)
    }

    @Test
    func totalTransitions_order0() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[0].totalTransitions == 4)
    }

    @Test
    func totalTransitions_order1() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().orderMetrics[1].totalTransitions == 5)
    }
}
