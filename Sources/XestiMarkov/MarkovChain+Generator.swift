// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Creates a new generator for this Markov chain at the given order.
    ///
    /// Returns `nil` when `order` is outside `0...maximumOrder`.
    ///
    /// - Parameter order:  The context order to use when selecting the next
    ///                     state. Defaults to ``defaultMarkovOrder``. Pass zero
    ///                     for a frequency-only generator.
    ///
    /// - Returns:  A generator seeded with a snapshot of the current chain
    ///             state, or `nil` if `order` is out of range.
    public func generator(order: Int = defaultMarkovOrder) -> (any Generator)? {
        SimpleGenerator(markovChain: self,
                        order: order)
    }

    // MARK: Public Type Methods

    /// Creates a generator that blends multiple sources at fixed weights.
    ///
    /// At each step the probability distribution is the weighted sum of each
    /// source's distribution, normalized by the total weight.
    ///
    /// - Parameter sources:    Two or more `(generator, weight)` pairs. Weights
    ///                         are unnormalized positive finite values.
    ///
    /// - Returns:  A blended generator.
    ///
    /// - Precondition: `sources` must not be empty; every weight must be finite
    ///                 and positive.
    public static func generator(blending sources: [(any Generator, weight: Double)]) -> any Generator {
        precondition(!sources.isEmpty,
                     "sources must not be empty")

        precondition(sources.allSatisfy { $0.weight.isFinite && $0.weight > 0 },
                     "every weight must be a finite positive Double")

        let totalWeight = sources.reduce(0.0) { $0 + $1.weight }
        let normalizedWeights = sources.map { $0.weight / totalWeight }
        let sourceGenerators = sources.map { $0.0 }
        let blendWeights: @Sendable (Int, [State]) -> [Double] = { _, _ in normalizedWeights }

        return BlendedGenerator(sources: sourceGenerators,
                                blendWeights: blendWeights)!    // swiftlint:disable:this force_unwrapping
    }

    /// Creates a generator that blends multiple sources with step-varying
    /// weights.
    ///
    /// The `weights` closure is called once per step and must return an array
    /// whose length equals `sources.count`. Negative or zero weights for a
    /// source cause that source's distribution to be excluded at that step.
    ///
    /// - Parameter sources:    The source generators to blend.
    /// - Parameter weights:    A closure that receives the current step index
    ///                         and preceding context and returns an array of
    ///                         blend weights, one per source.
    ///
    /// - Returns:  A blended generator with custom step-varying weights.
    ///
    /// - Precondition: `sources` must not be empty.
    public static func generator(blending sources: [any Generator],
                                 weights: @escaping @Sendable (_ step: Int, _ context: [State]) -> [Double]) -> any Generator {
        precondition(!sources.isEmpty,
                     "sources must not be empty")

        return BlendedGenerator(sources: sources,
                                blendWeights: weights)! // swiftlint:disable:this force_unwrapping
    }

    /// Creates a generator that adjusts the probability distribution using a
    /// contrast factor.
    ///
    /// Each probability `p` is raised to the power `contrast` before sampling.
    /// Values greater than `1.0` sharpen the distribution (making likely states
    /// more likely); values between `0.0` and `1.0` flatten it (making rare
    /// states more reachable). `1.0` leaves the distribution unchanged.
    ///
    /// - Parameter source:     The underlying generator.
    /// - Parameter contrast:   The contrast factor.
    ///
    /// - Returns:  A contrast-adjusted generator.
    ///
    /// - Precondition: `contrast` must be positive.
    public static func generator(contrasting source: any Generator,
                                 by contrast: Double) -> any Generator {
        precondition(contrast > 0,
                     "contrast must be positive")

        return ContrastGenerator(source: source,
                                 contrast: contrast)
    }

    /// Creates a generator that filters states using a predicate.
    ///
    /// Any candidate state for which `predicate` returns `false` is removed
    /// from the distribution before sampling. Terminal transitions (`.end`) are
    /// always retained. If the filtered distribution is empty, `next` returns
    /// `nil`.
    ///
    /// - Parameter source:     The underlying generator.
    /// - Parameter predicate:  Returns `true` for states that should be
    ///                         allowed.
    ///
    /// - Returns:  A filtering generator.
    public static func generator(filtering source: any Generator,
                                 where predicate: @escaping @Sendable (State) -> Bool) -> any Generator {
        FilterGenerator(source: source,
                        predicate: predicate)
    }

    /// Creates a generator that morphs from one source to another over a given
    /// number of steps.
    ///
    /// The blend starts fully at `from` and ends fully at `to` after `steps`
    /// steps; `interpolator` controls the rate of the transition.
    ///
    /// - Parameter from:           The starting generator.
    /// - Parameter to:             The ending generator.
    /// - Parameter steps:          The number of steps over which to interpolate.
    /// - Parameter interpolator:   Controls the rate of the blend transition.
    ///
    /// - Returns:  A morphing blended generator.
    ///
    /// - Precondition: `steps` must be positive.
    public static func generator(interpolating from: any Generator,
                                 to: any Generator,
                                 over steps: Int,
                                 using interpolator: some Interpolator) -> any Generator {
        precondition(steps > 0,
                     "steps must be positive")

        let blendWeights: @Sendable (Int, [State]) -> [Double] = { step, _ in
            let t = min(Double(step) / Double(steps), 1.0)
            let w = interpolator.checkedInterpolate(t)

            return [1.0 - w, w]
        }

        return BlendedGenerator(sources: [from, to],
                                blendWeights: blendWeights)!    // swiftlint:disable:this force_unwrapping
    }

    /// Creates a generator that restarts from the beginning whenever the source
    /// reaches a terminal state.
    ///
    /// When the underlying source returns `nil` during `generate(upTo:)` or
    /// `generate(until:)`, the internal history is reset and generation
    /// continues from `.begin`. For single-step `next(after:)` calls, one
    /// restart is attempted; if the source returns `nil` again, `nil` is
    /// returned.
    ///
    /// - Parameter source: The underlying generator to loop.
    ///
    /// - Returns:  A looping generator.
    public static func generator(looping source: any Generator) -> any Generator {
        LoopingGenerator(source: source)
    }

    /// Creates a generator that falls back to a secondary generator when the
    /// primary yields nothing.
    ///
    /// At each step the primary generator is tried first. If it returns `nil`
    /// (no distribution for the current context, or a terminal transition was
    /// selected), the secondary generator is used instead. When `committing` is
    /// `true`, the first fallback permanently switches all subsequent steps to
    /// the secondary.
    ///
    /// - Parameter primary:        The preferred generator.
    /// - Parameter secondary:      The generator used when the primary yields
    ///                             nothing.
    /// - Parameter  committing:    When `true`, the first fallback is
    ///                             permanent. Defaults to `false`.
    ///
    /// - Returns:  A fallback generator.
    public static func generator(trying primary: any Generator,
                                 otherwise secondary: any Generator,
                                 committing: Bool = false) -> any Generator {
        FallbackGenerator(primary: primary,
                          secondary: secondary,
                          committing: committing)
    }
}
