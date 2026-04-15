// © 2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiTools

/// The default order used when creating a ``Markov`` chain or
/// ``Markov/Generator``.
public let defaultMarkovOrder = 1

/// A Markov chain that models the statistical relationships between sequences
/// of events.
///
/// The _order_ of a Markov chain determines how many preceding events are used
/// as context when predicting the next event. A first-order Markov chain
/// considers only the immediately preceding event; a second-order Markov chain
/// considers the two most recent; and so on. A zeroth-order Markov chain
/// ignores history entirely and selects events by overall frequency. The
/// ``maximumOrder`` property sets the highest order the Markov chain tracks; a
/// ``Generator`` can be created at any order from zero up to that maximum.
///
/// Use an ``Analyzer`` to train the Markov chain on observed event sequences,
/// and a ``Generator`` to produce new event sequences based on the learned
/// probabilities. A Markov chain is thread-safe: multiple analyzers and
/// generators can operate on the same instance concurrently.
///
/// `Event` must conform to `Codable`, `Comparable`, `Hashable`, and `Sendable`.
public final class Markov<Event> where Event: Codable,
                                       Event: Comparable,
                                       Event: Hashable,
                                       Event: Sendable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.unsafeAccumulator = try container.decode(Accumulator.self,
                                                      forKey: .accumulator)

        self.unsafeInStateMap = try container.decode(StateMap<State>.self,
                                                     forKey: .inStateMap)

        self.maximumOrder = try container.decode(Int.self,
                                                 forKey: .maximumOrder)

        self.unsafeOutStateMap = try container.decode(StateMap<State>.self,
                                                      forKey: .outStateMap)
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
        self.unsafeInStateMap = StateMap()
        self.maximumOrder = maximumOrder
        self.unsafeOutStateMap = StateMap()
    }

    // MARK: Public Instance Properties

    /// The highest-order context tracked by this Markov chain.
    public let maximumOrder: Int

    // MARK: Private Instance Properties

    private let lock = NSLock(named: "XestiMarkov.Markov.lock")

    private var unsafeAccumulator: Accumulator
    private var unsafeInStateMap: StateMap<State>
    private var unsafeOutStateMap: StateMap<State>
}

// MARK: -

extension Markov {

    // MARK: Public Instance Methods

    /// Creates a new analyzer for this Markov chain.
    ///
    /// - Returns:  A new ``Analyzer`` instance that records event
    ///             observations into this Markov chain.
    public func analyzer() -> Analyzer {
        Analyzer(markov: self)
    }

    /// Creates a new generator for this Markov chain at the given order.
    ///
    /// If `order` is outside the range `0...maximumOrder`, this method returns
    /// `nil`.
    ///
    /// - Parameter order:  The context order to use when selecting the next
    ///                     event. Defaults to ``defaultMarkovOrder``. Pass zero
    ///                     for a zeroth-order (frequency-only) generator.
    ///
    /// - Returns:  A new ``Generator`` instance seeded with a snapshot of this
    ///             Markov chain’s current state, or `nil` if `order` is out of
    ///             range.
    public func generator(order: Int = defaultMarkovOrder) -> Generator? {
        Generator(markov: self,
                  order: order)
    }

    // MARK: Internal Nested Types

    internal typealias Snapshot = (inStateMap: StateMap<State>,
                                   outStateMap: StateMap<State>,
                                   accumulator: Accumulator)

    // MARK: Internal Instance Properties

    internal var snapshot: Snapshot {
        lock.withLock {
            (unsafeInStateMap, unsafeOutStateMap, unsafeAccumulator)
        }
    }

    // MARK: Internal Instance Methods

    internal func increment(inState: State,
                            outState: State) {
        lock.withLock {
            let (_, _, simpleOutState) = unsafeOutStateMap.insert(element: outState)
            let (_, _, simpleInState) = unsafeInStateMap.insert(element: inState)

            unsafeAccumulator.increment(inState: simpleInState,
                                        outState: simpleOutState)
        }
    }
}

// MARK: - Codable

extension Markov: Codable {

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let ss = snapshot

        //
        // Maintain order:
        //
        try container.encode(maximumOrder,
                             forKey: .maximumOrder)

        try container.encode(ss.inStateMap,
                             forKey: .inStateMap)

        try container.encode(ss.outStateMap,
                             forKey: .outStateMap)

        try container.encode(ss.accumulator,
                             forKey: .accumulator)
    }

    // MARK: Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case accumulator
        case inStateMap
        case maximumOrder
        case outStateMap
    }
}

// MARK: - Sendable

// Thread safety is guaranteed by the NSLock in `increment(inState:outState:)`
// and `snapshot`. The `unsafe*` stored properties must never be accessed
// outside of those two locked regions.
extension Markov: @unchecked Sendable {
}
