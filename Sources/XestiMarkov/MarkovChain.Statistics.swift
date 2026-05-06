// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Nested Types

    /// Statistics describing the training adequacy of a Markov chain at a
    /// specific order.
    ///
    /// Obtain an instance via ``MarkovChain/statistics(forOrder:)``.
    public struct Statistics {

        // MARK: Public Instance Properties

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

        /// The number of distinct states observed across all training.
        ///
        /// This is the global vocabulary size *k* used in the 10·*k*ⁿ adequacy
        /// heuristic. Identical regardless of which order's `Statistics` you
        /// inspect.
        public let distinctStates: Int

        /// The maximum number of weighted transitions recorded for any
        /// predecessor sequence.
        ///
        /// `0` when ``distinctPredecessors`` is `0`.
        public let maximumTransitions: Int

        /// The mean number of weighted transitions per predecessor sequence.
        ///
        /// `0.0` when ``distinctPredecessors`` is `0`.
        public let meanTransitions: Double

        /// The minimum number of weighted transitions recorded for any
        /// predecessor sequence.
        ///
        /// `0` when ``distinctPredecessors`` is `0`.
        public let minimumTransitions: Int

        /// The order these statistics describe.
        public let order: Int

        /// The total number of weighted transitions recorded at this order,
        /// summed across all predecessor sequences.
        public let totalTransitions: Int

        // MARK: Internal Initializers

        internal init(order: Int,
                      distinctStates: Int,
                      distinctPredecessors: Int,
                      totalTransitions: Int,
                      minimumTransitions: Int,
                      maximumTransitions: Int,
                      meanTransitions: Double,
                      branchingRatio: Double) {
            self.branchingRatio = branchingRatio
            self.distinctPredecessors = distinctPredecessors
            self.distinctStates = distinctStates
            self.maximumTransitions = maximumTransitions
            self.meanTransitions = meanTransitions
            self.minimumTransitions = minimumTransitions
            self.order = order
            self.totalTransitions = totalTransitions
        }
    }
}

// MARK: - Sendable

extension MarkovChain.Statistics: Sendable {
}
