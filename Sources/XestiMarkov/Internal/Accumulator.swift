// © 2026 John Gary Pusey (see LICENSE.md)

internal struct Accumulator {

    // MARK: Internal Initializers

    internal init() {
        self.inStateMap = [:]
        self.weightMap = [:]
    }

    // MARK: Internal Instance Properties

    internal private(set) var weightMap: [Key: UInt]

    // MARK: Private Instance Properties

    private var inStateMap: [Int: [Key: UInt]]
}

// MARK: -

extension Accumulator {

    // MARK: Internal Instance Properties

    internal var count: Int {
        weightMap.count
    }

    internal var isEmpty: Bool {
        weightMap.isEmpty
    }

    // MARK: Internal Instance Methods

    internal mutating func increment(inState: Int,
                                     outState: Int) {
        let key = Key(inState: inState,
                      outState: outState)
        let newWeight = weightMap[key, default: 0] + 1

        inStateMap[inState, default: [:]][key] = newWeight
        weightMap[key] = newWeight
    }

    internal func extractElements(for inState: Int) -> [Dictionary<Key, UInt>.Element] {
        Array(inStateMap[inState, default: [:]])
    }
}

// MARK: - Codable

extension Accumulator: Codable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var tmpWeightMap: [Key: UInt] = [:]

        while !container.isAtEnd {
            var nestedContainer = try container.nestedUnkeyedContainer()

            let inState = try nestedContainer.decode(Int.self)
            let outState = try nestedContainer.decode(Int.self)
            let key = Key(inState: inState,
                          outState: outState)

            tmpWeightMap[key] = try nestedContainer.decode(UInt.self)
        }

        var tmpInStateMap: [Int: [Key: UInt]] = [:]

        for (key, value) in tmpWeightMap {
            tmpInStateMap[key.inState, default: [:]][key] = value
        }

        self.inStateMap = tmpInStateMap
        self.weightMap = tmpWeightMap
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()

        for (key, value) in weightMap {
            var nestedContainer = container.nestedUnkeyedContainer()

            try nestedContainer.encode(key.inState)
            try nestedContainer.encode(key.outState)
            try nestedContainer.encode(value)
        }
    }
}

// MARK: - Sendable

extension Accumulator: Sendable {
}
