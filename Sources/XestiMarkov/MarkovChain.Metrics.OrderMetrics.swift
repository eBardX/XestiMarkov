// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain.Metrics {

    // MARK: Public Nested Types

    /// Per-order metrics for a Markov chain at a specific order.
    ///
    /// Obtain instances via ``MarkovChain/metrics()``.
    public struct OrderMetrics {

        // MARK: Public Instance Properties

        /// The training adequacy ratio at this order.
        ///
        /// `nil` for order `0` (not meaningful there) and when the chain is
        /// empty (avoids division by zero). Otherwise `totalTransitions /
        /// (10·kⁿ)`, where *k* is ``MarkovChain/Metrics/distinctStates`` and
        /// *n* is ``order``. A value ≥ `1.0` indicates adequate training for
        /// generation at this order; below `1.0` indicates increasingly poor
        /// generation quality.
        public let adequacyRatio: Double?

        /// The proportion of predecessor sequences that lead to two or more
        /// distinct possible successors, in `0.0...1.0`.
        ///
        /// Near `1.0` means the chain makes genuine probabilistic choices
        /// throughout; near `0.0` means most outcomes are deterministic. `0.0`
        /// when ``distinctPredecessors`` is `0`.
        public let branchingRatio: Double

        /// The number of distinct predecessor sequences of length ``order``
        /// observed during training.
        ///
        /// Always `0` for order 0: the zeroth-order chain tracks no predecessor
        /// sequences.
        public let distinctPredecessors: Int

        /// The maximum number of transitions recorded for any predecessor
        /// sequence.
        ///
        /// `0` when ``distinctPredecessors`` is `0`.
        public let maximumTransitions: Int

        /// The mean number of transitions per predecessor sequence.
        ///
        /// `0.0` when ``distinctPredecessors`` is `0`.
        public let meanTransitions: Double

        /// The minimum number of transitions recorded for any predecessor
        /// sequence.
        ///
        /// `0` when ``distinctPredecessors`` is `0`.
        public let minimumTransitions: Int

        /// The order these metrics describe.
        ///
        /// Equal to the index of this value in
        /// ``MarkovChain/Metrics/orderMetrics``.
        public let order: Int

        /// The total number of transitions recorded at this order, summed
        /// across all predecessor sequences.
        public let totalTransitions: Int

        // MARK: Internal Initializers

        internal init(order: Int,
                      adequacyRatio: Double?,
                      distinctPredecessors: Int,
                      totalTransitions: Int,
                      minimumTransitions: Int,
                      maximumTransitions: Int,
                      meanTransitions: Double,
                      branchingRatio: Double) {
            self.adequacyRatio = adequacyRatio
            self.branchingRatio = branchingRatio
            self.distinctPredecessors = distinctPredecessors
            self.maximumTransitions = maximumTransitions
            self.meanTransitions = meanTransitions
            self.minimumTransitions = minimumTransitions
            self.order = order
            self.totalTransitions = totalTransitions
        }
    }
}

// MARK: - Sendable

extension MarkovChain.Metrics.OrderMetrics: Sendable {
}
