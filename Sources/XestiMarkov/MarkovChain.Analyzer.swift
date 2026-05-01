// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Nested Types

    /// A type that analyzes sequences of states and records the observed
    /// transitions into a Markov chain.
    ///
    /// You can create an analyzer via ``MarkovChain/analyzer()``. Call
    /// ``analyze(_:)`` one or more times to train the Markov chain on the
    /// provided state sequences.
    public struct Analyzer {

        // MARK: Public Instance Properties

        /// The Markov chain into which this analyzer records observations.
        public let markovChain: MarkovChain
    }
}

// MARK: -

extension MarkovChain.Analyzer {

    // MARK: Public Instance Methods

    /// Analyzes the provided state sequence and records the observed
    /// transitions into the Markov chain.
    ///
    /// - Parameter states:    The sequence of states to analyze.
    public func analyze(_ states: [State]) {
        let contexts: [Context<State>] = states.map { .single($0) }

        _analyze0(contexts: contexts)

        let enhancedContexts = [.begin] + contexts + [.end]

        _analyze1(contexts: enhancedContexts)

        guard markovChain.maximumOrder > 1
        else { return }

        for order in 2...markovChain.maximumOrder {
            _analyzeN(contexts: enhancedContexts,
                      order: order)
        }
    }

    // MARK: Private Instance Methods

    private func _analyze0(contexts: [Context<State>]) {
        for context in contexts {
            markovChain.increment(inContext: .zero,
                                  outContext: context)
        }
    }

    private func _analyze1(contexts: [Context<State>]) {
        for idx in 0..<(contexts.count - 1) {
            let nextContext = contexts[idx + 1]
            let currContext = contexts[idx]

            if currContext.canAppend(context: nextContext) {
                markovChain.increment(inContext: currContext,
                                      outContext: nextContext)
            }
        }
    }

    private func _analyzeN(contexts: [Context<State>],
                           order: Int) {
        for idx in 0..<(contexts.count - order) {
            let nextIdx = idx + order
            let currContext = _combineSlice(contexts: contexts[idx..<nextIdx])
            let nextContext = contexts[nextIdx]

            if currContext.canAppend(context: nextContext) {
                markovChain.increment(inContext: currContext,
                                      outContext: nextContext)
            }
        }
    }

    private func _combineSlice(contexts: ArraySlice<Context<State>>) -> Context<State> {
        contexts.reduce(into: .zero) {
            $0.append(context: $1,
                      limit: contexts.count)
        }
    }
}
