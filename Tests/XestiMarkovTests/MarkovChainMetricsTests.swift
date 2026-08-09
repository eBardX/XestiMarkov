// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct MarkovChainMetricsTests {
}

// MARK: -

extension MarkovChainMetricsTests {
    @Test
    func metrics_distinctInitialStates_emptyChain() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.metrics().distinctInitialStates == 0)
    }

    @Test
    func metrics_distinctInitialStates_multipleSequences() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))
        let analyzer = markovChain.analyzer()

        analyzer.analyze(sequence: ["a", "b"])
        analyzer.analyze(sequence: ["c", "d"])

        #expect(markovChain.metrics().distinctInitialStates == 2)
    }

    @Test
    func metrics_distinctInitialStates_singleSequence() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().distinctInitialStates == 1)
    }

    @Test
    func metrics_distinctStates_afterTraining() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().distinctStates == 3)
    }

    @Test
    func metrics_distinctStates_emptyChain() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.metrics().distinctStates == 0)
    }

    @Test
    func metrics_orderMetrics_count() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        #expect(markovChain.metrics().orderMetrics.count == 3)
    }

    @Test
    func metrics_orderMetrics_orderValues() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))

        markovChain.analyzer().analyze(sequence: ["a", "b", "c"])

        let m = markovChain.metrics()

        for i in 0..<m.orderMetrics.count {
            #expect(m.orderMetrics[i].order == i)
        }
    }

    @Test
    func metrics_recommendedOrder_adequate() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))
        let sequence = (0..<11).flatMap { _ in ["a", "b"] }

        markovChain.analyzer().analyze(sequence: sequence)

        #expect(markovChain.metrics().recommendedOrder == 1)
    }

    @Test
    func metrics_recommendedOrder_emptyChain() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        #expect(markovChain.metrics().recommendedOrder == nil)
    }

    @Test
    func metrics_recommendedOrder_multipleAdequate_choosesHighest() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 2))
        let sequence = (0..<100).flatMap { _ in ["a", "b"] }

        markovChain.analyzer().analyze(sequence: sequence)

        let metrics = markovChain.metrics()

        // Both order 1 and order 2 are adequately trained here; recommendedOrder
        // must pick the highest of the two, not merely the first adequate one.
        #expect(metrics.orderMetrics[1].adequacyRatio.map { $0 >= 1.0 } == true)
        #expect(metrics.orderMetrics[2].adequacyRatio.map { $0 >= 1.0 } == true)
        #expect(metrics.recommendedOrder == 2)
    }

    @Test
    func metrics_recommendedOrder_noneAdequate() throws {
        let markovChain = try #require(MarkovChain<String>(maximumOrder: 1))

        markovChain.analyzer().analyze(sequence: ["a", "b", "a", "c"])

        #expect(markovChain.metrics().recommendedOrder == nil)
    }
}
