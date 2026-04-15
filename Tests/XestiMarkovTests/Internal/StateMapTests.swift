// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct StateMapTests {
}

// MARK: -

extension StateMapTests {
    @Test
    func count_empty() {
        let expectedValue = 0

        let smap = StateMap<String>()

        #expect(smap.count == expectedValue)
    }

    @Test
    func count_notEmpty() {
        let expectedValue = 11

        var smap = StateMap<String>()

        for idx in 0..<expectedValue {
            smap.insert(element: "fubar-\(idx)")
        }

        #expect(smap.count == expectedValue)
    }

    @Test
    func insert_duplicate() {
        let expectedElement = "fubar-7"
        let expectedInserted = false
        let expectedIndex = 7

        var smap = StateMap<String>()

        for idx in 0..<11 {
            smap.insert(element: "fubar-\(idx)")
        }

        let actualResult = smap.insert(element: expectedElement)

        #expect(actualResult.element == expectedElement)
        #expect(actualResult.inserted == expectedInserted)
        #expect(actualResult.state == expectedIndex)
    }

    @Test
    func insert_empty() {
        let expectedElement = "numpty"
        let expectedInserted = true
        let expectedIndex = 0

        var smap = StateMap<String>()

        let actualResult = smap.insert(element: expectedElement)

        #expect(actualResult.element == expectedElement)
        #expect(actualResult.inserted == expectedInserted)
        #expect(actualResult.state == expectedIndex)
    }

    @Test
    func insert_notEmpty() {
        let expectedElement = "numpty"
        let expectedInserted = true
        let expectedIndex = 11

        var smap = StateMap<String>()

        for idx in 0..<11 {
            smap.insert(element: "fubar-\(idx)")
        }

        let actualResult = smap.insert(element: expectedElement)

        #expect(actualResult.element == expectedElement)
        #expect(actualResult.inserted == expectedInserted)
        #expect(actualResult.state == expectedIndex)
    }

    @Test
    func subscriptElement_empty() {
        let expectedValue: Int? = nil

        let smap = StateMap<String>()

        #expect(smap["bogus"] == expectedValue)
    }

    @Test
    func subscriptElement_found() {
        let expectedValue: Int = 7

        var smap = StateMap<String>()

        for idx in 0..<11 {
            smap.insert(element: "fubar-\(idx)")
        }

        #expect(smap["fubar-7"] == expectedValue)
    }

    @Test
    func subscriptElement_missing() {
        let expectedValue: Int? = nil

        var smap = StateMap<String>()

        for idx in 0..<11 {
            smap.insert(element: "fubar-\(idx)")
        }

        #expect(smap["bogus-1"] == expectedValue)
        #expect(smap["fubar-11"] == expectedValue)
    }

    @Test
    func subscriptState_empty() {
        let expectedValue: String? = nil

        let smap = StateMap<String>()

        #expect(smap[666] == expectedValue)
    }

    @Test
    func subscriptState_found() {
        let expectedValue = "fubar-7"

        var smap = StateMap<String>()

        for idx in 0..<11 {
            smap.insert(element: "fubar-\(idx)")
        }

        #expect(smap[7] == expectedValue)
    }

    @Test
    func subscriptState_outOfRange() {
        let expectedValue: String? = nil

        var smap = StateMap<String>()

        for idx in 0..<11 {
            smap.insert(element: "fubar-\(idx)")
        }

        #expect(smap[-13] == expectedValue)
        #expect(smap[666] == expectedValue)
    }
}
