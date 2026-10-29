# ``XestiMarkov``

@Metadata {
    @PageColor(blue)
}

Markov chain tools.

## Overview

The XestiMarkov framework provides a collection of Markov chain tools for Swift.
A ``MarkovChain`` learns the statistical relationships between states from
observed sequences, and its generators produce new sequences that follow the
learned probabilities:

- **Train** a Markov chain of any maximum order with an
  ``MarkovChain/Analyzer``, either one sequence at a time or many at once, or
  by merging another Markov chain.
- **Generate** new sequences at any order from zero up to that maximum, with
  ``MarkovChain/generator(order:startsAtBegin:stopsAtEnd:using:)``.
- **Compose** generators into richer ones by blending, contrasting, filtering,
  interpolating, looping, or falling back from one to another.
- **Inspect** what was learned: iterate or filter the recorded transitions,
  calculate the empirical probability of a transition, and measure how
  adequately each order has been trained.

States can be any type that is `Codable`, `Comparable`, `Hashable`, and
`Sendable`. A Markov chain is itself `Codable`, so it can be saved and
restored, and it is thread-safe, so multiple analyzers and generators can
operate on the same instance concurrently.

```swift
import XestiMarkov

// Train a second-order Markov chain on the letters of some words.
let words = ["banana", "bandana", "cabana", "canal", "panama"]
let markovChain = MarkovChain<String>(maximumOrder: 2)!

markovChain.analyzer().analyze(sequences: words.map { $0.map(String.init) })

// Generate a new word, reproducibly, at order 2.
var generator = markovChain.generator(order: 2,
                                      using: SeededRandomNumberGenerator(seed: 42))!

let newWord = generator.generate(upTo: 12).joined()

// Back off to order 1 wherever order 2 has nothing to offer.
let order1 = markovChain.generator(order: 1)!
var backingOff = MarkovChain<String>.generator(trying: generator,
                                               otherwise: order1)

let anotherWord = backingOff.generate(upTo: 12).joined()
```

Every generator accepts an optional random number generator; pass a
``SeededRandomNumberGenerator`` to make generation reproducible.

## Topics

### Essentials

- ``MarkovChain``
- ``defaultMarkovOrder``

### Training

- ``MarkovChain/Analyzer``

### Generating

- ``MarkovChainGenerator``
- ``MarkovChain/Generator``
- ``SeededRandomNumberGenerator``

### Inspecting

- ``MarkovChain/Transition``
- ``MarkovChain/Metrics``
