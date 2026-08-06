// © 2026 John Gary Pusey (see LICENSE.md)

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Calculates the empirical probability of `target` following `source`.
    ///
    /// If `source` is `.states([])` or has never been observed, this method
    /// returns `nil`. If `source` has been observed but `target` has never
    /// followed it, this method returns `0.0`.
    ///
    /// - Parameter target:  The transition target for which to calculate the
    ///                      probability.
    /// - Parameter source:  The transition source that precedes `target`.
    ///
    /// - Returns:  The probability of `target` following `source`, in the range
    ///             `0.0...1.0`, or `nil` if `source` is `.states([])` or has
    ///             never been observed.
    public func probability(of target: Transition.Target,
                            after source: Transition.Source) -> Double? {
        guard let inContext = _inContext(for: source),
              let outContext = _outContext(for: target)
        else { return nil }

        let ss = snapshot

        guard let inIndex = ss.inContextMap[inContext]
        else { return nil }

        let elements = ss.accumulator.extractElements(for: inIndex)

        guard !elements.isEmpty
        else { return nil }

        let totalWeight = elements.reduce(UInt(0)) { $0 + $1.value }

        guard totalWeight > 0
        else { return nil }

        guard let outIndex = ss.outContextMap[outContext]
        else { return 0.0 }

        let key = Accumulator.Key(inIndex: inIndex,
                                  outIndex: outIndex)
        let weight = ss.accumulator.weightMap[key] ?? 0

        return Double(weight) / Double(totalWeight)
    }

    // MARK: Private Instance Methods

    private func _inContext(for source: Transition.Source) -> Context<State>? {
        switch source {
        case .begin:
            return .begin

        case let .states(states):
            guard !states.isEmpty
            else { return nil }

            var context: Context<State> = .zero

            for state in states {
                context.append(context: .single(state),
                               limit: states.count)
            }

            return context

        case .zero:
            return .zero
        }
    }

    private func _outContext(for target: Transition.Target) -> Context<State>? {
        switch target {
        case .end:
            .end

        case let .state(state):
            .single(state)
        }
    }
}
