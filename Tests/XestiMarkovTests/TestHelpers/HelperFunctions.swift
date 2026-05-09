// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

internal func makeAccumulatorKey(_ inIndex: Int,
                                 _ outIndex: Int) -> Accumulator.Key {
    Accumulator.Key(inIndex: inIndex,
                    outIndex: outIndex)
}

internal func makeContext<State>(_ contexts: [Context<State>]) -> Context<State> where State: Codable,
                                                                                       State: Comparable,
                                                                                       State: Hashable,
                                                                                       State: Sendable {
    var seq = ContextSequence<State>()

    for context in contexts {
        seq.append(context: context,
                   limit: contexts.count)
    }

    return .sequence(seq)
}

internal func makeContextSequence<State>(_ contexts: [Context<State>],
                                         limit: Int? = nil) -> ContextSequence<State> where State: Codable,
                                                                                            State: Comparable,
                                                                                            State: Hashable,
                                                                                            State: Sendable {
    contexts.reduce(into: ContextSequence<State>()) {
        $0.append(context: $1,
                  limit: limit ?? contexts.count)
    }
}

internal func verifyContextAppend<State>(_ context1: Context<State>,
                                         _ context2: Context<State>,
                                         _ expectedContext: Context<State>,
                                         limit: Int? = nil) where State: Codable,
                                                                  State: Comparable,
                                                                  State: Hashable,
                                                                  State: Sendable {
    var context = context1

    context.append(context: context2,
                   limit: limit ?? 100)

    #expect(context == expectedContext)
}

internal func verifyContextSequenceAppend<State>(_ inContexts: [Context<State>],
                                                 _ context: Context<State>,
                                                 _ expectedContexts: [Context<State>],
                                                 limit: Int? = nil) where State: Codable,
                                                                          State: Comparable,
                                                                          State: Hashable,
                                                                          State: Sendable {
    var seq = makeContextSequence(inContexts, limit: limit)

    seq.append(context: context,
               limit: limit ?? expectedContexts.count)

    #expect(Array(seq) == expectedContexts)
}
