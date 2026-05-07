// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Nested Types

    /// Metrics describing the training of a Markov chain across all supported
    /// orders.
    ///
    /// Obtain an instance via ``MarkovChain/metrics()``.
    public struct Metrics {

        // MARK: Public Instance Properties

        /// The number of distinct states that can appear as the first element
        /// of a generated sequence.
        ///
        /// `0` when the chain has not been trained.
        public let distinctInitialStates: Int

        /// The number of distinct states observed across all training.
        ///
        /// This is the global vocabulary size *k* used in the `10·kⁿ` adequacy
        /// heuristic.
        public let distinctStates: Int

        /// Per-order metrics, indexed by order, covering `0` through
        /// `maximumOrder`.
        public let orderMetrics: [OrderMetrics]

        /// The highest order greater than `0` for which
        /// ``OrderMetrics/adequacyRatio`` is ≥ `1.0`, or `nil` if no such order
        /// exists.
        ///
        /// Use this to choose a generation order: training is adequate at this
        /// order; orders above it have increasingly sparse data.
        public let recommendedOrder: Int?

        // MARK: Internal Initializers

        internal init(distinctStates: Int,
                      distinctInitialStates: Int,
                      recommendedOrder: Int?,
                      orderMetrics: [OrderMetrics]) {
            self.distinctInitialStates = distinctInitialStates
            self.distinctStates = distinctStates
            self.orderMetrics = orderMetrics
            self.recommendedOrder = recommendedOrder
        }
    }
}

// MARK: - Sendable

extension MarkovChain.Metrics: Sendable {
}
