// © 2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiTools

/// The default order used when creating a ``MarkovChain`` or
/// ``MarkovChain/Generator``.
public let defaultMarkovOrder = 1

/// A Markov chain that models the statistical relationships between sequences
/// of states.
///
/// The _order_ of a Markov chain determines how many preceding states are used
/// as context when predicting the next state. A first-order Markov chain
/// considers only the immediately preceding state; a second-order Markov chain
/// considers the two most recent; and so on. A zeroth-order Markov chain
/// ignores history entirely and selects states by overall frequency. The
/// ``maximumOrder`` property sets the highest order the Markov chain tracks; a
/// ``Generator`` can be created at any order from zero up to that maximum.
///
/// Use an ``Analyzer`` to train the Markov chain on observed state sequences,
/// and a ``Generator`` to produce new state sequences based on the learned
/// probabilities. A Markov chain is thread-safe: multiple analyzers and
/// generators can operate on the same instance concurrently.
public final class MarkovChain<State> where State: Codable,
                                            State: Comparable,
                                            State: Hashable,
                                            State: Sendable {

    // MARK: Public Initializers

    /// Creates a new Markov chain by decoding from the given decoder.
    ///
    /// - Parameter decoder:    The decoder from which to read data.
    ///
    /// - Throws:   `DecodingError` if required data is missing or corrupted.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.unsafeAccumulator = try container.decode(Accumulator.self,
                                                      forKey: .accumulator)

        self.unsafeInContextMap = try container.decode(IndexMap<Context<State>>.self,
                                                       forKey: .inContextMap)

        self.maximumOrder = try container.decode(Int.self,
                                                 forKey: .maximumOrder)

        self.unsafeOutContextMap = try container.decode(IndexMap<Context<State>>.self,
                                                        forKey: .outContextMap)
    }

    /// Creates a new, empty Markov chain with the given maximum order.
    ///
    /// If `maximumOrder` is less than or equal to zero, this initializer
    /// returns `nil`.
    ///
    /// - Parameter maximumOrder:   The highest-order context the Markov chain
    ///                             will track. Defaults to
    ///                             ``defaultMarkovOrder``.
    public init?(maximumOrder: Int = defaultMarkovOrder) {
        guard maximumOrder > 0
        else { return nil }

        self.unsafeAccumulator = Accumulator()
        self.unsafeInContextMap = IndexMap()
        self.maximumOrder = maximumOrder
        self.unsafeOutContextMap = IndexMap()
    }

    // MARK: Public Instance Properties

    /// The highest-order context tracked by this Markov chain.
    public let maximumOrder: Int

    // MARK: Private Instance Properties

    private let lock = NSLock(named: "XestiMarkov.MarkovChain.lock")

    private var unsafeAccumulator: Accumulator
    private var unsafeInContextMap: IndexMap<Context<State>>
    private var unsafeOutContextMap: IndexMap<Context<State>>
}

// MARK: -

extension MarkovChain {

    // MARK: Public Instance Methods

    /// Creates a new analyzer for this Markov chain.
    ///
    /// - Returns:  A new ``Analyzer`` instance that records state
    ///             observations into this Markov chain.
    public func analyzer() -> Analyzer {
        Analyzer(markovChain: self)
    }

    /// Creates a new generator for this Markov chain at the given order.
    ///
    /// If `order` is outside the range `0...maximumOrder`, this method returns
    /// `nil`.
    ///
    /// - Parameter order:  The context order to use when selecting the next
    ///                     state. Defaults to ``defaultMarkovOrder``. Pass zero
    ///                     for a zeroth-order (frequency-only) generator.
    ///
    /// - Returns:  A new ``Generator`` instance seeded with a snapshot of the
    ///             current state of this Markov chain, or `nil` if `order` is
    ///             out of range.
    public func generator(order: Int = defaultMarkovOrder) -> Generator? {
        Generator(markovChain: self,
                  order: order)
    }

    // MARK: Internal Type Aliases

    internal typealias Snapshot = (inContextMap: IndexMap<Context<State>>,
                                   outContextMap: IndexMap<Context<State>>,
                                   accumulator: Accumulator)

    // MARK: Internal Instance Properties

    internal var snapshot: Snapshot {
        lock.withLock {
            (unsafeInContextMap, unsafeOutContextMap, unsafeAccumulator)
        }
    }

    // MARK: Internal Instance Methods

    internal func increment(inContext: Context<State>,
                            outContext: Context<State>) {
        lock.withLock {
            let (_, _, outIndex) = unsafeOutContextMap.insert(element: outContext)
            let (_, _, inIndex) = unsafeInContextMap.insert(element: inContext)

            unsafeAccumulator.increment(inIndex: inIndex,
                                        outIndex: outIndex)
        }
    }
}

// MARK: - Codable

extension MarkovChain: Codable {

    // MARK: Public Instance Methods

    /// Encodes this Markov chain into the given encoder.
    ///
    /// - Parameter encoder:    The encoder to which to write data.
    ///
    /// - Throws:   `EncodingError` if a value fails to encode.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let ss = snapshot

        //
        // Maintain order:
        //
        try container.encode(maximumOrder,
                             forKey: .maximumOrder)

        try container.encode(ss.inContextMap,
                             forKey: .inContextMap)

        try container.encode(ss.outContextMap,
                             forKey: .outContextMap)

        try container.encode(ss.accumulator,
                             forKey: .accumulator)
    }

    // MARK: Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case accumulator
        case inContextMap
        case maximumOrder
        case outContextMap
    }
}

// MARK: - Sendable

// Thread safety is guaranteed by the NSLock in
// `increment(inContext:outContext:)` and `snapshot`. The `unsafe*` stored
// properties must never be accessed outside of those two locked regions.
extension MarkovChain: @unchecked Sendable {
}
