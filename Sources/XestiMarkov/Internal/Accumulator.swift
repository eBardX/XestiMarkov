// © 2026 John Gary Pusey (see LICENSE.md)

internal struct Accumulator {

    // MARK: Internal Initializers

    internal init() {
        self.inIndexMap = [:]
        self.weightMap = [:]
    }

    // MARK: Internal Instance Properties

    internal private(set) var weightMap: [Key: UInt]

    // MARK: Private Instance Properties

    private var inIndexMap: [Int: [Key: UInt]]
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

    internal mutating func increment(inIndex: Int,
                                     outIndex: Int,
                                     by weight: UInt = 1) {
        let key = Key(inIndex: inIndex,
                      outIndex: outIndex)
        let newWeight = weightMap[key, default: 0] + weight

        inIndexMap[inIndex, default: [:]][key] = newWeight
        weightMap[key] = newWeight
    }

    internal func extractElements(for inIndex: Int) -> [Dictionary<Key, UInt>.Element] {
        Array(inIndexMap[inIndex, default: [:]])
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

            let inIndex = try nestedContainer.decode(Int.self)
            let outIndex = try nestedContainer.decode(Int.self)
            let key = Key(inIndex: inIndex,
                          outIndex: outIndex)

            tmpWeightMap[key] = try nestedContainer.decode(UInt.self)
        }

        var tmpInIndexMap: [Int: [Key: UInt]] = [:]

        for (key, value) in tmpWeightMap {
            tmpInIndexMap[key.inIndex, default: [:]][key] = value
        }

        self.inIndexMap = tmpInIndexMap
        self.weightMap = tmpWeightMap
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()

        for (key, value) in weightMap {
            var nestedContainer = container.nestedUnkeyedContainer()

            try nestedContainer.encode(key.inIndex)
            try nestedContainer.encode(key.outIndex)
            try nestedContainer.encode(value)
        }
    }
}

// MARK: - Sendable

extension Accumulator: Sendable {
}
