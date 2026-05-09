// © 2026 John Gary Pusey (see LICENSE.md)

internal struct IndexMap<Element> where Element: Codable,
                                        Element: Hashable,
                                        Element: Sendable {

    // MARK: Internal Type Aliases

    internal typealias InsertResult = (inserted: Bool, element: Element, index: Int)

    // MARK: Internal Initializers

    internal init() {
        self.elementToIndex = [:]
        self.indexToElement = []
    }

    // MARK: Internal Instance Properties

    internal private(set) var elementToIndex: [Element: Int]
    internal private(set) var indexToElement: [Element]
}

// MARK: -

extension IndexMap {

    // MARK: Internal Instance Properties

    internal var count: Int {
        indexToElement.count
    }

    internal var isEmpty: Bool {
        indexToElement.isEmpty
    }

    // MARK: Internal Instance Methods

    @discardableResult
    internal mutating func insert(element: Element) -> InsertResult {
        if let index = elementToIndex[element] {
            return (false, indexToElement[index], index)
        }

        let index = indexToElement.count

        elementToIndex[element] = index

        indexToElement.insert(element,
                              at: index)

        return (true, element, index)
    }

    // MARK: Internal Subscripts

    internal subscript(element: Element) -> Int? {
        elementToIndex[element]
    }

    internal subscript(index: Int) -> Element? {
        guard (0..<indexToElement.count) ~= index
        else { return nil }

        return indexToElement[index]
    }
}

// MARK: - Codable

extension IndexMap: Codable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var tmpIndexToElement: [Element] = []

        while !container.isAtEnd {
            try tmpIndexToElement.append(container.decode(Element.self))
        }

        var tmpElementToIndex: [Element: Int] = [:]

        for (idx, elt) in tmpIndexToElement.enumerated() {
            tmpElementToIndex[elt] = idx
        }

        self.elementToIndex = tmpElementToIndex
        self.indexToElement = tmpIndexToElement
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in indexToElement {
            try container.encode(element)
        }
    }
}

// MARK: - Sendable

extension IndexMap: Sendable {
}
