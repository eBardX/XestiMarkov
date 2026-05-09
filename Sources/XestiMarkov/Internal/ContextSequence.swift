// © 2026 John Gary Pusey (see LICENSE.md)

internal struct ContextSequence<State>: Sequence where State: Codable,
                                                       State: Comparable,
                                                       State: Hashable,
                                                       State: Sendable {

    // MARK: Internal Instance Properties

    internal private(set) var contexts: [Context<State>]

    // MARK: Internal Initializers

    internal init() {
        self.contexts = []
    }
}

// MARK: -

extension ContextSequence {

    // MARK: Internal Instance Properties

    @inlinable internal var count: Int {
        contexts.count
    }

    @inlinable internal var last: Context<State>? {
        contexts.last
    }

    // MARK: Internal Instance Methods

    internal mutating func append(context: Context<State>,
                                  limit: Int) {
        let lastContext = contexts.last ?? .zero

        switch (lastContext, context) {
        case (.begin, .begin),
            (.single, .begin),
            (.end, _),
            (_, .sequence),
            (_, .zero):
            break

        case (.zero, _):
            contexts = [context]

        default:
            contexts.append(context)
        }

        if contexts.count > limit {
            contexts = Array(contexts.suffix(limit))
        }
    }

    @inlinable
    internal func makeIterator() -> IndexingIterator<[Context<State>]> {
        contexts.makeIterator()
    }

    // MARK: Internal Subscripts

    @inlinable
    internal subscript(index: Int) -> Context<State> {
        contexts[index]
    }
}

// MARK: - Codable

extension ContextSequence: Codable {
}

// MARK: - Comparable

extension ContextSequence: Comparable {
    internal static func < (lhs: Self,
                            rhs: Self) -> Bool {
        lhs.contexts.lexicographicallyPrecedes(rhs.contexts)
    }
}

// MARK: - Hashable

extension ContextSequence: Hashable {
}

// MARK: - Sendable

extension ContextSequence: Sendable {
}
