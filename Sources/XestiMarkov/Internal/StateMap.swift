// © 2026 John Gary Pusey (see LICENSE.md)

internal struct StateMap<Element> where Element: Codable,
                                        Element: Hashable,
                                        Element: Sendable {

    // MARK: Internal Nested Types

    internal typealias InsertResult = (inserted: Bool, element: Element, state: Int)

    // MARK: Internal Initializers

    internal init() {
        self.elementToState = [:]
        self.stateToElement = []
    }

    // MARK: Internal Instance Properties

    internal private(set) var elementToState: [Element: Int]
    internal private(set) var stateToElement: [Element]
}

// MARK: -

extension StateMap {

    // MARK: Internal Instance Properties

    internal var count: Int {
        stateToElement.count
    }

    internal var isEmpty: Bool {
        stateToElement.isEmpty
    }

    // MARK: Internal Instance Methods

    @discardableResult
    internal mutating func insert(element: Element) -> InsertResult {
        if let state = elementToState[element] {
            return (false, stateToElement[state], state)
        }

        let state = stateToElement.count

        elementToState[element] = state

        stateToElement.insert(element,
                              at: state)

        return (true, element, state)
    }

    // MARK: Internal Subscripts

    internal subscript(element: Element) -> Int? {
        elementToState[element]
    }

    internal subscript(state: Int) -> Element? {
        guard (0..<stateToElement.count) ~= state
        else { return nil }

        return stateToElement[state]
    }
}

// MARK: - Codable

extension StateMap: Codable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var tmpStateToElement: [Element] = []

        while !container.isAtEnd {
            try tmpStateToElement.append(container.decode(Element.self))
        }

        var tmpElementToState: [Element: Int] = [:]

        for (idx, elt) in tmpStateToElement.enumerated() {
            tmpElementToState[elt] = idx
        }

        self.elementToState = tmpElementToState
        self.stateToElement = tmpStateToElement
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in stateToElement {
            try container.encode(element)
        }
    }
}

// MARK: - Sendable

extension StateMap: Sendable {
}
