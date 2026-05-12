// © 2026 John Gary Pusey (see LICENSE.md)

internal enum Context<State> where State: Codable,
                                   State: Comparable,
                                   State: Hashable,
                                   State: Sendable {
    case begin
    case end
    case sequence(ContextSequence<State>)
    case single(State)
    case zero
}

// MARK: -

extension Context {

    // MARK: Internal Instance Properties

    internal var hasNext: Bool {
        switch self {
        case .end:
            false

        case let .sequence(seq):
            seq.last?.hasNext ?? false

        default:
            true
        }
    }

    internal var order: Int? {
        switch self {
        case .zero:
            0

        case .begin,
             .single:
            1

        case let .sequence(seq):
            seq.count

        case .end:
            nil
        }
    }

    // MARK: Internal Instance Methods

    internal mutating func append(context: Self,
                                  limit: Int) {
        var seq = _selfAsSequence()

        seq.append(context: context,
                   limit: limit)

        self = switch seq.count {
        case 0:
            .zero

        case 1:
            seq[0]

        default:
            .sequence(seq)
        }
    }

    internal func canAppend(context: Self) -> Bool {
        switch (self, context) {
        case (_, .begin),
             (_, .sequence),
             (_, .zero),
             (.end, _),
             (.zero, .end):
            false

        case let (.sequence(seq), _):
            seq.last?.canAppend(context: context) ?? false

        case (.begin, .end),
             (.begin, .single),
             (.single, .end),
             (.single, .single),
             (.zero, .single):
            true
        }
    }

    // MARK: Private Instance Methods

    private func _selfAsSequence() -> ContextSequence<State> {
        switch self {
        case let .sequence(seq):
            return seq

        default:
            var seq = ContextSequence<State>()

            seq.append(context: self,
                       limit: 1)

            return seq
        }
    }
}

// MARK: - Codable

extension Context: Codable {

    // MARK: Internal Initializers

    internal init(from decoder: any Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()

            self = try Self._decode(from: &container)
        } catch {
            var container = try decoder.singleValueContainer()

            self = try Self._decode(from: &container)
        }
    }

    // MARK: Internal Instance Methods

    internal func encode(to encoder: any Encoder) throws {
        switch self {
        case .begin,
             .end,
             .zero:
            var container = encoder.singleValueContainer()

            try _encode(to: &container)

        case .sequence,
             .single:
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
            try .sequence(container.decode(ContextSequence<State>.self))

        case "single":
            try .single(container.decode(State.self))

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
        case let .sequence(seq):
            try container.encode("sequence")
            try container.encode(seq)

        case let .single(state):
            try container.encode("single")
            try container.encode(state)

        default:
            throw EncodingError.invalidValue(self,
                                             EncodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Internal encoding cockup!"))
        }
    }
}

// MARK: - Comparable

extension Context: Comparable {
    internal static func < (lhs: Self,
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

        case let (.sequence(lseq), .sequence(rseq)):
            lseq < rseq

        case let (.single(lstate), .single(rstate)):
            lstate < rstate

        default:
            false
        }
    }
}

// MARK: - Hashable

extension Context: Hashable {
}

// MARK: - Sendable

extension Context: Sendable {
}
