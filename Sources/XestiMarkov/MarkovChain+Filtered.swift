// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Creates a new Markov chain containing only the transitions of this
    /// Markov chain that satisfy the given predicate.
    ///
    /// The new Markov chain has the same ``maximumOrder`` as this one, and
    /// each transition it keeps has the same weight. Contexts keep their
    /// anchoring at the start of a sequence, so the new Markov chain begins
    /// generation just as this one does wherever its transitions are kept.
    /// This Markov chain is not changed.
    ///
    /// - Parameter isIncluded: Called with each ``Transition`` of this Markov
    ///                         chain. Return `true` to keep it.
    ///
    /// - Returns:  A new Markov chain with the selected transitions.
    ///
    /// - Throws:   Any error thrown by `isIncluded`.
    public func filtered(where isIncluded: (Transition) throws -> Bool) rethrows -> MarkovChain {
        let ss = snapshot
        let result = MarkovChain(maximumOrder: maximumOrder).require()

        for (key, weight) in ss.accumulator.weightMap.sorted(by: { $0.key < $1.key }) {
            guard let inContext = ss.inContextMap[key.inIndex],
                  let outContext = ss.outContextMap[key.outIndex],
                  let transition = makeTransition(inContext: inContext,
                                                  outContext: outContext,
                                                  weight: weight),
                  try isIncluded(transition)
            else { continue }

            result.increment(inContext: inContext,
                             outContext: outContext,
                             by: weight)
        }

        return result
    }
}
