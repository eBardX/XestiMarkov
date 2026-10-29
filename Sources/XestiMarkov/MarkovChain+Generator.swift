// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension MarkovChain {

    // MARK: Public Type Methods

    /// Creates a generator that blends multiple sources at fixed weights.
    ///
    /// At each step the probability distribution is the weighted sum of each
    /// source’s distribution, normalized by the total weight. Each source’s
    /// distribution is itself normalized first, so a source’s influence
    /// depends only on its weight. A source with no distribution for the
    /// current context is left out, and the remaining weights are
    /// renormalized.
    ///
    /// - Parameter sources:    Two or more `(generator, weight)` pairs. Weights
    ///                         are unnormalized positive finite values.
    /// - Parameter rng:        The random number generator to sample with.
    ///                         Pass a ``SeededRandomNumberGenerator`` for
    ///                         reproducible results. Defaults to the system
    ///                         random number generator.
    ///
    /// - Returns:  A blended generator.
    ///
    /// - Precondition: `sources` must not be empty; every weight must be finite
    ///                 and positive.
    public static func generator(blending sources: [(any Generator, weight: Double)],
                                 using rng: some (RandomNumberGenerator & Sendable) = SystemRandomNumberGenerator()) -> any Generator {
        precondition(!sources.isEmpty,
                     "sources must not be empty")

        precondition(sources.allSatisfy { $0.weight.isFinite && $0.weight > 0 },
                     "every weight must be a finite positive Double")

        let totalWeight = sources.reduce(0.0) { $0 + $1.weight }
        let normalizedWeights = sources.map { $0.weight / totalWeight }
        let sourceGenerators = sources.map { $0.0 }
        let blendWeights: @Sendable (Int, [State]) -> [Double] = { _, _ in normalizedWeights }

        return BlendedGenerator(sources: sourceGenerators,
                                blendWeights: blendWeights,
                                rng: AnyRandomNumberGenerator(rng)).require()
    }

    /// Creates a generator that blends multiple sources with step-varying
    /// weights.
    ///
    /// The `weights` closure is called once per step and must return an array
    /// whose length equals `sources.count`. Negative or zero weights for a
    /// source cause that source’s distribution to be excluded at that step.
    /// As with fixed weights, each source’s distribution is normalized before
    /// its weight is applied.
    ///
    /// - Parameter sources:    The source generators to blend.
    /// - Parameter weights:    A closure that receives the current step index
    ///                         and preceding context and returns an array of
    ///                         blend weights, one per source.
    /// - Parameter rng:        The random number generator to sample with.
    ///                         Pass a ``SeededRandomNumberGenerator`` for
    ///                         reproducible results. Defaults to the system
    ///                         random number generator.
    ///
    /// - Returns:  A blended generator with custom step-varying weights.
    ///
    /// - Precondition: `sources` must not be empty.
    public static func generator(blending sources: [any Generator],
                                 weights: @escaping @Sendable (_ step: Int, _ context: [State]) -> [Double],
                                 using rng: some (RandomNumberGenerator & Sendable) = SystemRandomNumberGenerator()) -> any Generator {
        precondition(!sources.isEmpty,
                     "sources must not be empty")

        return BlendedGenerator(sources: sources,
                                blendWeights: weights,
                                rng: AnyRandomNumberGenerator(rng)).require()
    }

    /// Creates a generator that adjusts the probability distribution using a
    /// contrast factor.
    ///
    /// Each probability `p` is raised to the power `contrast` before sampling.
    /// Values greater than `1.0` sharpen the distribution (making likely states
    /// more likely); values between `0.0` and `1.0` flatten it (making rare
    /// states more reachable). `1.0` leaves the distribution unchanged. The
    /// result is renormalized to sum to `1.0`.
    ///
    /// - Parameter source:     The underlying generator.
    /// - Parameter contrast:   The contrast factor.
    /// - Parameter rng:        The random number generator to sample with.
    ///                         Pass a ``SeededRandomNumberGenerator`` for
    ///                         reproducible results. Defaults to the system
    ///                         random number generator.
    ///
    /// - Returns:  A contrast-adjusted generator.
    ///
    /// - Precondition: `contrast` must be positive.
    public static func generator(contrasting source: any Generator,
                                 by contrast: Double,
                                 using rng: some (RandomNumberGenerator & Sendable) = SystemRandomNumberGenerator()) -> any Generator {
        precondition(contrast > 0,
                     "contrast must be positive")

        return ContrastGenerator(source: source,
                                 contrast: contrast,
                                 rng: AnyRandomNumberGenerator(rng))
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
    /// - Parameter rng:        The random number generator to sample with.
    ///                         Pass a ``SeededRandomNumberGenerator`` for
    ///                         reproducible results. Defaults to the system
    ///                         random number generator.
    ///
    /// - Returns:  A filtering generator.
    public static func generator(filtering source: any Generator,
                                 where predicate: @escaping @Sendable (State) -> Bool,
                                 using rng: some (RandomNumberGenerator & Sendable) = SystemRandomNumberGenerator()) -> any Generator {
        FilterGenerator(source: source,
                        predicate: predicate,
                        rng: AnyRandomNumberGenerator(rng))
    }

    /// Creates a generator that morphs from one source to another over a given
    /// number of steps.
    ///
    /// The blend starts fully at `from` and ends fully at `to` after `steps`
    /// steps; `interpolator` controls the rate of the transition (for example,
    /// `LinearInterpolator()` for a steady morph).
    ///
    /// - Parameter from:           The starting generator.
    /// - Parameter to:             The ending generator.
    /// - Parameter steps:          The number of steps over which to interpolate.
    /// - Parameter interpolator:   Controls the rate of the blend transition.
    /// - Parameter rng:            The random number generator to sample with.
    ///                             Pass a ``SeededRandomNumberGenerator`` for
    ///                             reproducible results. Defaults to the
    ///                             system random number generator.
    ///
    /// - Returns:  A morphing blended generator.
    ///
    /// - Precondition: `steps` must be positive.
    public static func generator(interpolating from: any Generator,
                                 to: any Generator,
                                 over steps: Int,
                                 along interpolator: some Interpolator,
                                 using rng: some (RandomNumberGenerator & Sendable) = SystemRandomNumberGenerator()) -> any Generator {
        precondition(steps > 0,
                     "steps must be positive")

        let blendWeights: @Sendable (Int, [State]) -> [Double] = { step, _ in
            let t = min(Double(step) / Double(steps), 1.0)
            let w = interpolator.checkedInterpolate(t)

            return [1.0 - w, w]
        }

        return BlendedGenerator(sources: [from, to],
                                blendWeights: blendWeights,
                                rng: AnyRandomNumberGenerator(rng)).require()
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
    /// - Parameter source:  The underlying generator to loop.
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
    /// selected), the secondary generator is used instead, with the same
    /// preceding states. Falling back to a lower-order generator of the same
    /// Markov chain therefore backs off to a shorter context. When `committing` is
    /// `true`, the first fallback permanently switches all subsequent steps to
    /// the secondary.
    ///
    /// - Parameter primary:        The preferred generator.
    /// - Parameter secondary:      The generator used when the primary yields
    ///                             nothing.
    /// - Parameter committing:     When `true`, the first fallback is
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

    // MARK: Public Instance Methods

    /// Creates a new generator for this Markov chain at the given order.
    ///
    /// Returns `nil` when `order` is outside `0...maximumOrder`.
    ///
    /// By default, generation begins at the implicit start of a sequence, so
    /// its first states follow the openings observed during training, and it
    /// stops when the end of a sequence is chosen. Either can be turned off:
    ///
    /// - When `startsAtBegin` is `false`, the first state is chosen by overall
    ///   frequency (as at order zero), and the context then builds up from
    ///   the states generated so far, without the implicit start: one state,
    ///   then two, up to `order`. The same applies in
    ///   ``MarkovChainGenerator/next(after:)`` when fewer than `order` states
    ///   are given.
    /// - When `stopsAtEnd` is `false`, the end of a sequence is never chosen.
    ///   Where no other successor exists for the current context (or the
    ///   context was never observed), the generator backs off to successively
    ///   shorter contexts, down to order zero, which has no end. Generation
    ///   then continues until the limit or predicate stops it.
    ///
    /// Neither option affects a zeroth-order generator.
    ///
    /// - Parameter order:          The context order to use when selecting the
    ///                             next state. Defaults to
    ///                             ``defaultMarkovOrder``. Pass zero for a
    ///                             frequency-only generator.
    /// - Parameter startsAtBegin:  Whether generation begins at the implicit
    ///                             start of a sequence. Defaults to `true`.
    /// - Parameter stopsAtEnd:     Whether the implicit end of a sequence can
    ///                             be chosen. Defaults to `true`.
    /// - Parameter rng:            The random number generator to sample with.
    ///                             Pass a ``SeededRandomNumberGenerator`` for
    ///                             reproducible results. Defaults to the
    ///                             system random number generator.
    ///
    /// - Returns:  A generator seeded with a snapshot of the current chain
    ///             state, or `nil` if `order` is out of range.
    public func generator(order: Int = defaultMarkovOrder,
                          startsAtBegin: Bool = true,
                          stopsAtEnd: Bool = true,
                          using rng: some (RandomNumberGenerator & Sendable) = SystemRandomNumberGenerator()) -> (any Generator)? {
        SimpleGenerator(markovChain: self,
                        order: order,
                        startsAtBegin: startsAtBegin,
                        stopsAtEnd: stopsAtEnd,
                        rng: AnyRandomNumberGenerator(rng))
    }
}
