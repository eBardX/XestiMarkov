// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Returns statistics describing the training adequacy of this Markov chain
    /// at the given order.
    ///
    /// Returns `nil` if `order` is outside `0...maximumOrder`.
    ///
    /// - Parameter order:  The order for which to compute statistics. Pass `0`
    ///                     for zeroth-order (frequency-only) statistics.
    ///
    /// - Returns:  A ``Statistics`` value for the requested order, or `nil` if
    ///             `order` is out of range.
    public func statistics(forOrder order: Int) -> Statistics? {
        guard (0...maximumOrder).contains(order)
        else { return nil }

        let ss = snapshot
        let distinctStates = ss.outContextMap.indexToElement.filter {
            if case .single = $0 {
                true
            } else {
                false
            }
        }.count

        var predWeights: [Int] = []
        var branchingCount = 0
        var totalTransitions = 0

        for (inIndex, inContext) in ss.inContextMap.indexToElement.enumerated() {
            guard inContext.order == order
            else { continue }

            let elements = ss.accumulator.extractElements(for: inIndex)

            guard !elements.isEmpty
            else { continue }

            let weight = elements.reduce(0) { $0 + Int($1.value) }

            predWeights.append(weight)

            totalTransitions += weight

            if elements.count > 1 {
                branchingCount += 1
            }
        }

        // Order 0: distinctPredecessors is always 0 by definition;
        // per-predecessor metrics are not applicable since .zero is not a
        // predecessor sequence.
        guard order != 0,
              !predWeights.isEmpty
        else { return Statistics(order: order,
                                 distinctStates: distinctStates,
                                 distinctPredecessors: 0,
                                 totalTransitions: totalTransitions,
                                 minimumTransitions: 0,
                                 maximumTransitions: 0,
                                 meanTransitions: 0.0,
                                 branchingRatio: 0.0) }

        let n = predWeights.count

        return Statistics(order: order,
                          distinctStates: distinctStates,
                          distinctPredecessors: n,
                          totalTransitions: totalTransitions,
                          minimumTransitions: predWeights.min() ?? 0,
                          maximumTransitions: predWeights.max() ?? 0,
                          meanTransitions: Double(totalTransitions) / Double(n),
                          branchingRatio: Double(branchingCount) / Double(n))
    }
}
