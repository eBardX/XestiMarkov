// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Returns metrics describing the training of this Markov chain across all
    /// supported orders.
    ///
    /// - Returns:  A ``Metrics`` value covering orders `0` through
    ///             ``maximumOrder``.
    public func metrics() -> Metrics {
        let ss = snapshot

        let distinctStates = ss.outContextMap.indexToElement.filter {
            if case .single = $0 {
                true
            } else {
                false
            }
        }.count

        let distinctInitialStates: Int

        if let beginIndex = ss.inContextMap[.begin] {
            distinctInitialStates = ss.accumulator.extractElements(for: beginIndex).filter {
                if let outContext = ss.outContextMap[$0.key.outIndex],
                   case .single = outContext {
                    true
                } else {
                    false
                }
            }.count
        } else {
            distinctInitialStates = 0
        }

        var allOrderMetrics: [Metrics.OrderMetrics] = []

        for order in 0...maximumOrder {
            allOrderMetrics.append(buildOrderMetrics(order: order,
                                                     distinctStates: distinctStates,
                                                     snapshot: ss))
        }

        let recommendedOrder = allOrderMetrics.last {
            guard $0.order > 0,
                  let ratio = $0.adequacyRatio
            else { return false }

            return ratio >= 1.0
        }.map(\.order)

        return Metrics(distinctStates: distinctStates,
                       distinctInitialStates: distinctInitialStates,
                       recommendedOrder: recommendedOrder,
                       orderMetrics: allOrderMetrics)
    }
}

// MARK: -

private extension MarkovChain {
    func buildOrderMetrics(order: Int,
                           distinctStates: Int,
                           snapshot ss: Snapshot) -> Metrics.OrderMetrics {
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

        let kPowN = (0..<order).reduce(1.0) { acc, _ in acc * Double(distinctStates) }
        let adequacyRatio: Double?

        if order > 0, distinctStates > 0 {
            adequacyRatio = Double(totalTransitions) / (10.0 * kPowN)
        } else {
            adequacyRatio = nil
        }

        guard order != 0,
              !predWeights.isEmpty
        else { return Metrics.OrderMetrics(order: order,
                                           adequacyRatio: adequacyRatio,
                                           distinctPredecessors: 0,
                                           totalTransitions: totalTransitions,
                                           minimumTransitions: 0,
                                           maximumTransitions: 0,
                                           meanTransitions: 0.0,
                                           branchingRatio: 0.0) }

        let n = predWeights.count

        return Metrics.OrderMetrics(order: order,
                                    adequacyRatio: adequacyRatio,
                                    distinctPredecessors: n,
                                    totalTransitions: totalTransitions,
                                    minimumTransitions: predWeights.min() ?? 0,
                                    maximumTransitions: predWeights.max() ?? 0,
                                    meanTransitions: Double(totalTransitions) / Double(n),
                                    branchingRatio: Double(branchingCount) / Double(n))
    }
}
