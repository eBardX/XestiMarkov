// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

internal func makeAccumulatorKey(_ inState: Int,
                                 _ outState: Int) -> Accumulator.Key {
    Accumulator.Key(inState: inState,
                    outState: outState)
}

internal func makeMarkovState<Event>(_ states: [Markov<Event>.State]) -> Markov<Event>.State where Event: Codable,
                                                                                                   Event: Comparable,
                                                                                                   Event: Hashable,
                                                                                                   Event: Sendable {
                                                                                                       var mss = Markov<Event>.StateSequence()

                                                                                                       for state in states {
                                                                                                           mss.append(state: state,
                                                                                                                      limit: states.count)
                                                                                                       }

                                                                                                       return .sequence(mss)
                                                                                                   }

internal func makeStateSequence<Event>(_ states: [Markov<Event>.State],
                                       limit: Int? = nil) -> Markov<Event>.StateSequence where Event: Codable,
                                                                                               Event: Comparable,
                                                                                               Event: Hashable,
                                                                                               Event: Sendable {
                                                                                                   states.reduce(into: Markov<Event>.StateSequence()) { // swiftlint:disable:this line_length
                                                                                                       $0.append(state: $1,
                                                                                                                 limit: limit ?? states.count)
                                                                                                   }
                                                                                               }

internal func verifyMarkovStateAppend<Event>(_ state1: Markov<Event>.State,
                                             _ state2: Markov<Event>.State,
                                             _ expectedState: Markov<Event>.State,
                                             limit: Int? = nil) where Event: Codable,
                                                                      Event: Comparable,
                                                                      Event: Hashable,
                                                                      Event: Sendable {
                                                                          var state = state1

                                                                          state.append(state: state2,
                                                                                       limit: limit ?? 100)

                                                                          #expect(state == expectedState)
                                                                      }

internal func verifyStateSequenceAppend<Event>(_ inStates: [Markov<Event>.State],
                                               _ state: Markov<Event>.State,
                                               _ expectedStates: [Markov<Event>.State],
                                               limit: Int? = nil) where Event: Codable,
                                                                        Event: Comparable,
                                                                        Event: Hashable,
                                                                        Event: Sendable {
                                                                            var seq = makeStateSequence(inStates, limit: limit)

                                                                            seq.append(state: state,
                                                                                       limit: limit ?? expectedStates.count)

                                                                            #expect(Array(seq) == expectedStates)
                                                                        }
