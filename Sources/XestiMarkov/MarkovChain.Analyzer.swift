// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Nested Types

    /// A type that analyzes sequences of states and records the observed
    /// transitions into a Markov chain.
    ///
    /// You can create an analyzer via ``MarkovChain/analyzer()``. Call
    /// ``analyze(sequence:)`` one or more times to train the Markov chain on
    /// the provided state sequences.
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
    /// If `states` is empty, this method has no effect.
    ///
    /// - Parameter states: The sequence of states to analyze.
    ///
    /// - Note: Renamed to ``analyze(sequence:)``.
    @available(*, deprecated, renamed: "analyze(sequence:)")
    public func analyze(_ states: [State]) {
        analyze(sequence: states)
    }

    /// Analyzes the provided state sequence and records the observed
    /// transitions into the Markov chain.
    ///
    /// If `sequence` is empty, this method has no effect.
    ///
    /// - Parameter sequence:   The sequence of states to analyze.
    public func analyze(sequence: [State]) {
        guard !sequence.isEmpty
        else { return }

        let contexts: [Context<State>] = sequence.map { .single($0) }

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

    /// Analyzes each of the provided state sequences and records the observed
    /// transitions into the Markov chain.
    ///
    /// This is equivalent to calling ``analyze(sequence:)`` once per sequence.
    /// Each sequence is treated as an independent observation: begin and end
    /// markers are implied per sequence, not across all sequences.
    ///
    /// - Parameter sequences:  The sequences of states to analyze.
    public func analyze(sequences: [[State]]) {
        for sequence in sequences {
            analyze(sequence: sequence)
        }
    }

    /// Merges all recorded transitions from the provided Markov chain into the
    /// Markov chain associated with this analyzer.
    ///
    /// Higher-order contexts from the provided Markov chain that exceed the
    /// ``MarkovChain/maximumOrder`` of the associated Markov chain are silently
    /// ignored.
    ///
    /// - Parameter other:  The Markov chain to merge.
    public func merge(_ other: MarkovChain<State>) {
        let (sourceInMap, sourceOutMap, sourceAccumulator) = other.snapshot

        for (key, weight) in sourceAccumulator.weightMap {
            guard let inContext = sourceInMap[key.inIndex]
            else { continue }

            guard let outContext = sourceOutMap[key.outIndex]
            else { continue }

            guard let order = inContext.order,
                  order <= markovChain.maximumOrder
            else { continue }

            for _ in 0..<weight {
                markovChain.increment(inContext: inContext,
                                      outContext: outContext)
            }
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
