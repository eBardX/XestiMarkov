// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

struct IndexMapTests {
}

// MARK: -

extension IndexMapTests {
    @Test
    func count_empty() {
        let expectedValue = 0

        let imap = IndexMap<String>()

        #expect(imap.count == expectedValue)
    }

    @Test
    func count_notEmpty() {
        let expectedValue = 11

        var imap = IndexMap<String>()

        for idx in 0..<expectedValue {
            imap.insert(element: "fubar-\(idx)")
        }

        #expect(imap.count == expectedValue)
    }

    @Test
    func insert_duplicate() {
        let expectedElement = "fubar-7"
        let expectedInserted = false
        let expectedIndex = 7

        var imap = IndexMap<String>()

        for idx in 0..<11 {
            imap.insert(element: "fubar-\(idx)")
        }

        let actualResult = imap.insert(element: expectedElement)

        #expect(actualResult.element == expectedElement)
        #expect(actualResult.inserted == expectedInserted)
        #expect(actualResult.index == expectedIndex)
    }

    @Test
    func insert_empty() {
        let expectedElement = "numpty"
        let expectedInserted = true
        let expectedIndex = 0

        var imap = IndexMap<String>()

        let actualResult = imap.insert(element: expectedElement)

        #expect(actualResult.element == expectedElement)
        #expect(actualResult.inserted == expectedInserted)
        #expect(actualResult.index == expectedIndex)
    }

    @Test
    func insert_notEmpty() {
        let expectedElement = "numpty"
        let expectedInserted = true
        let expectedIndex = 11

        var imap = IndexMap<String>()

        for idx in 0..<11 {
            imap.insert(element: "fubar-\(idx)")
        }

        let actualResult = imap.insert(element: expectedElement)

        #expect(actualResult.element == expectedElement)
        #expect(actualResult.inserted == expectedInserted)
        #expect(actualResult.index == expectedIndex)
    }

    @Test
    func subscriptElement_empty() {
        let expectedValue: Int? = nil

        let imap = IndexMap<String>()

        #expect(imap["bogus"] == expectedValue)
    }

    @Test
    func subscriptElement_found() {
        let expectedValue: Int = 7

        var imap = IndexMap<String>()

        for idx in 0..<11 {
            imap.insert(element: "fubar-\(idx)")
        }

        #expect(imap["fubar-7"] == expectedValue)
    }

    @Test
    func subscriptElement_missing() {
        let expectedValue: Int? = nil

        var imap = IndexMap<String>()

        for idx in 0..<11 {
            imap.insert(element: "fubar-\(idx)")
        }

        #expect(imap["bogus-1"] == expectedValue)
        #expect(imap["fubar-11"] == expectedValue)
    }

    @Test
    func subscriptIndex_empty() {
        let expectedValue: String? = nil

        let imap = IndexMap<String>()

        #expect(imap[666] == expectedValue)
    }

    @Test
    func subscriptIndex_found() {
        let expectedValue = "fubar-7"

        var imap = IndexMap<String>()

        for idx in 0..<11 {
            imap.insert(element: "fubar-\(idx)")
        }

        #expect(imap[7] == expectedValue)
    }

    @Test
    func subscriptIndex_outOfRange() {
        let expectedValue: String? = nil

        var imap = IndexMap<String>()

        for idx in 0..<11 {
            imap.insert(element: "fubar-\(idx)")
        }

        #expect(imap[-13] == expectedValue)
        #expect(imap[666] == expectedValue)
    }
}
