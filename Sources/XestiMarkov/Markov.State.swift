// © 2026 John Gary Pusey (see LICENSE.md)

extension Markov {

    // MARK: Public Nested Types

    /// A state in a Markov chain, representing the context used to model
    /// transitions between events.
    ///
    /// A state can be one of five kinds:
    /// - ``begin`` and ``end`` mark the boundaries of an event sequence.
    /// - ``single(_:)`` wraps a single event.
    /// - ``sequence(_:)`` wraps an ordered sequence of states used for higher-order
    ///   context.
    /// - ``zero`` is the root state from which zeroth-order transitions originate.
    public enum State {
        /// The implicit state that precedes the first event in a sequence.
        case begin

        /// The implicit state that follows the last event in a sequence.
        case end

        /// A state composed of an ordered sequence of states, used to represent
        /// higher-order context.
        case sequence(StateSequence)

        /// A state wrapping a single event.
        case single(Event)

        /// The root state used for zeroth-order (frequency-only) transitions.
        case zero
    }
}

// MARK: -

extension Markov.State {

    // MARK: Internal Instance Properties

    internal var hasNext: Bool {
        switch self {
        case .end:
            false

        case let .sequence(states):
            states.last?.hasNext ?? false

        default:
            true
        }
    }

    // MARK: Internal Instance Methods

    internal mutating func append(state: Self,
                                  limit: Int) {
        var states = _selfAsSequence()

        states.append(state: state,
                      limit: limit)

        switch states.count {
        case 0:
            self = .zero

        case 1:
            self = states[0]

        default:
            self = .sequence(states)
        }
    }

    internal func canAppend(state: Self) -> Bool {
        switch (self, state) {
        case (_, .begin),
            (_, .sequence),
            (_, .zero),
            (.end, _),
            (.zero, .end):
            false

        case let (.sequence(seq), _):
            seq.last?.canAppend(state: state) ?? false

        case (.begin, .end),
            (.begin, .single),
            (.single, .end),
            (.single, .single),
            (.zero, .single):
            true
        }
    }

    // MARK: Private Instance Methods

    private func _selfAsSequence() -> Markov.StateSequence {
        switch self {
        case let .sequence(states):
            return states

        default:
            var states = Markov.StateSequence()

            states.append(state: self,
                          limit: 1)

            return states
        }
    }
}

// MARK: - Codable

extension Markov.State: Codable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()

            self = try Self._decode(from: &container)
        } catch {
            var container = try decoder.singleValueContainer()

            self = try Self._decode(from: &container)
        }
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .begin, .end, .zero:
            var container = encoder.singleValueContainer()

            try _encode(to: &container)

        case .sequence, .single:
            var container = encoder.unkeyedContainer()

            try _encode(to: &container)
        }
    }

    // MARK: Private Type Methods

    private static func _decode(from container: inout any SingleValueDecodingContainer) throws -> Self {
        switch try container.decode(String.self) {
        case "begin":
                .begin

        case "end":
                .end

        case "zero":
                .zero

        default:
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid Markov state value")
        }
    }

    private static func _decode(from container: inout any UnkeyedDecodingContainer) throws -> Self {
        switch try container.decode(String.self) {
        case "sequence":
            try .sequence(container.decode(Markov.StateSequence.self))

        case "single":
            try .single(container.decode(Event.self))

        default:
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid Markov state value")
        }
    }

    // MARK: Private Instance Methods

    private func _encode(to container: inout any SingleValueEncodingContainer) throws {
        switch self {
        case .begin:
            try container.encode("begin")

        case .end:
            try container.encode("end")

        case .zero:
            try container.encode("zero")

        default:
            throw EncodingError.invalidValue(self,
                                             EncodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Internal encoding cockup!"))
        }
    }

    private func _encode(to container: inout any UnkeyedEncodingContainer) throws {
        switch self {
        case let .sequence(events):
            try container.encode("sequence")
            try container.encode(events)

        case let .single(event):
            try container.encode("single")
            try container.encode(event)

        default:
            throw EncodingError.invalidValue(self,
                                             EncodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Internal encoding cockup!"))
        }
    }
}

// MARK: - Comparable

extension Markov.State: Comparable {
    public static func < (lhs: Self,
                          rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.begin, .end),
            (.begin, .sequence),
            (.begin, .single),
            (.sequence, .end),
            (.single, .end),
            (.single, .sequence),
            (.zero, .begin),
            (.zero, .end),
            (.zero, .sequence),
            (.zero, .single):
            true

        case let (.sequence(levents), .sequence(revents)):
            levents < revents

        case let (.single(levent), .single(revent)):
            levent < revent

        default:
            false
        }
    }
}

// MARK: - Hashable

extension Markov.State: Hashable {
}

// MARK: - Sendable

extension Markov.State: Sendable {
}
