// © 2026 John Gary Pusey (see LICENSE.md)

internal struct SimpleMarkovChain {

    // MARK: Internal Initializers

    internal init(accumulator: Accumulator,
                  rng: AnyRandomNumberGenerator) {
        self.inOutMap = Self._makeInOutMap(accumulator)
        self.rng = rng
    }

    // MARK: Private Instance Properties

    private let inOutMap: InOutMap

    private var rng: AnyRandomNumberGenerator
}

// MARK: -

extension SimpleMarkovChain {

    // MARK: Internal Instance Methods

    internal mutating func next(after inIndex: Int,
                                excluding excludedOutIndex: Int? = nil) -> Int? {
        let totalWeight = totalWeight(after: inIndex,
                                      excluding: excludedOutIndex)

        guard totalWeight > 0,
              let outPairs = inOutMap[inIndex]
        else { return nil }

        let roll = UInt.random(in: 0..<totalWeight,
                               using: &rng)

        var runWeight: UInt = 0

        for outPair in outPairs where outPair.outIndex != excludedOutIndex {
            runWeight += outPair.weight

            if roll < runWeight {
                return outPair.outIndex
            }
        }

        return nil
    }

    internal func totalWeight(after inIndex: Int,
                              excluding excludedOutIndex: Int? = nil) -> UInt {
        guard let outPairs = inOutMap[inIndex]
        else { return 0 }

        return outPairs.reduce(0) {
            $1.outIndex == excludedOutIndex ? $0 : $0 + $1.weight
        }
    }

    // MARK: Private Type Aliases

    private typealias InOutMap = [Int: [OutPair]]
    private typealias OutPair  = (outIndex: Int, weight: UInt)

    // MARK: Private Type Methods

    private static func _makeInOutMap(_ accumulator: Accumulator) -> InOutMap {
        var inOutMap: InOutMap = [:]

        //
        // Sort so that a seeded random number generator always samples the
        // same way; dictionary order varies from one process to the next.
        //
        for (key, value) in accumulator.weightMap.sorted(by: { $0.key < $1.key }) {
            inOutMap[key.inIndex, default: []].append((key.outIndex, value))
        }

        return inOutMap
    }
}
