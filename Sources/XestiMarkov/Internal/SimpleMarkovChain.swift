// © 2026 John Gary Pusey (see LICENSE.md)

internal struct SimpleMarkovChain {

    // MARK: Internal Initializers

    internal init(accumulator: Accumulator,
                  rng: AnyRandomNumberGenerator) {
        self.inOutMap = Self._makeInOutMap(accumulator)
        self.rng = rng
    }

    // MARK: Internal Instance Methods

    internal mutating func next(after inIndex: Int) -> Int? {
        guard let outGroup = inOutMap[inIndex]
        else { return nil }

        let roll = UInt.random(in: 0..<outGroup.totalWeight,
                               using: &rng)

        for outPair in outGroup.outPairs where roll < outPair.runWeight {
            return outPair.outIndex
        }

        return nil
    }

    // MARK: Private Nested Types

    private typealias OutGroup = (totalWeight: UInt, outPairs: [OutPair])
    private typealias OutPair  = (outIndex: Int, runWeight: UInt)
    private typealias InOutMap = [Int: OutGroup]

    // MARK: Private Type Methods

    private static func _makeInOutMap(_ accumulator: Accumulator) -> InOutMap {
        var rawMap: [Int: [OutPair]] = [:]

        for (key, value) in accumulator.weightMap {
            rawMap[key.inIndex, default: []].append((key.outIndex, value))
        }

        var inOutMap: InOutMap = [:]

        for (inIndex, outPairs) in rawMap {
            var runWeight: UInt = 0

            let cumulativePairs = outPairs.map { pair -> OutPair in
                runWeight += pair.runWeight

                return (pair.outIndex, runWeight)
            }

            inOutMap[inIndex] = (runWeight, cumulativePairs)
        }

        return inOutMap
    }

    // MARK: Private Instance Properties

    private let inOutMap: InOutMap

    private var rng: AnyRandomNumberGenerator
}
