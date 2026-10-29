// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Type Aliases

    /// The generator type for a Markov chain.
    ///
    /// Use this typealias to write `any MarkovChain<State>.Generator` instead
    /// of the top-level `any MarkovChainGenerator<State>`.
    public typealias Generator = MarkovChainGenerator<State>
}
