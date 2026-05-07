// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Returns statistics describing the training adequacy of this Markov chain
    /// at the given order.
    ///
    /// - Parameter order:  The order for which to compute statistics. Pass `0`
    ///                     for zeroth-order (frequency-only) statistics.
    ///
    /// - Returns:  A ``Statistics`` value for the requested order, or `nil` if
    ///             `order` is outside `0...maximumOrder`.
    @available(*, deprecated, renamed: "metrics()")
    public func statistics(forOrder order: Int) -> Statistics? {
        guard (0...maximumOrder).contains(order)
        else { return nil }

        let m = metrics()
        let om = m.orderMetrics[order]

        return Statistics(order: om.order,
                          distinctStates: m.distinctStates,
                          distinctPredecessors: om.distinctPredecessors,
                          totalTransitions: om.totalTransitions,
                          minimumTransitions: om.minimumTransitions,
                          maximumTransitions: om.maximumTransitions,
                          meanTransitions: om.meanTransitions,
                          branchingRatio: om.branchingRatio)
    }
}
