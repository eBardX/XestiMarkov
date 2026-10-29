// © 2026 John Gary Pusey (see LICENSE.md)

import Testing
@testable import XestiMarkov

internal func allTransitions<State>(of markovChain: MarkovChain<State>) -> [MarkovChain<State>.Transition] {
    var result: [MarkovChain<State>.Transition] = []

    markovChain.forEach { result.append($0) }

    return result
}

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

internal func makeSeededGeneratorStack(_ markovChain: MarkovChain<Int>,
                                       seed: UInt64) throws -> any MarkovChain<Int>.Generator {
    var rng = SeededRandomNumberGenerator(seed: seed)

    let order2 = try #require(markovChain.generator(order: 2,
                                                    stopsAtEnd: false,
                                                    using: SeededRandomNumberGenerator(seed: rng.next())))
    let order1 = try #require(markovChain.generator(order: 1,
                                                    stopsAtEnd: false,
                                                    using: SeededRandomNumberGenerator(seed: rng.next())))
    let blend = MarkovChain<Int>.generator(blending: [(order2, weight: 0.7), (order1, weight: 0.3)],
                                           using: SeededRandomNumberGenerator(seed: rng.next()))

    return MarkovChain<Int>.generator(contrasting: blend,
                                      by: 0.8,
                                      using: SeededRandomNumberGenerator(seed: rng.next()))
}

internal func transitionMentions(_ transition: MarkovChain<String>.Transition,
                                 _ state: String) -> Bool {
    if transition.target == .state(state) {
        return true
    }

    switch transition.source {
    case let .beginStates(states),
         let .states(states):
        return states.contains(state)

    case .begin,
         .zero:
        return false
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
