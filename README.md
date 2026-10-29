# XestiMarkov

Markov chain tools.

## <a name="overview">Overview</a>

The XestiMarkov framework provides a collection of Markov chain tools for Swift.
A `MarkovChain` learns the statistical relationships between states from
observed sequences, and its generators produce new sequences that follow the
learned probabilities:

* **Train** a Markov chain of any maximum order with an `Analyzer`, either one
  sequence at a time or many at once, or by merging another Markov chain.
* **Generate** new sequences at any order from zero up to that maximum, with
  optional control over whether generation starts at the beginning of a
  sequence and whether it can stop at the end.
* **Compose** generators into richer ones by blending, contrasting, filtering,
  interpolating, looping, or falling back from one to another.
* **Inspect** what was learned: iterate or filter the recorded transitions,
  calculate the empirical probability of a transition, and measure how
  adequately each order has been trained.

States can be any type that is `Codable`, `Comparable`, `Hashable`, and
`Sendable`. A Markov chain is itself `Codable`, so it can be saved and
restored, and it is thread-safe, so multiple analyzers and generators can
operate on the same instance concurrently.

Generators are created through factory methods on `MarkovChain`, all of which
return `any MarkovChain<State>.Generator`:

 Factory method                                     | Generator
:---------------------------------------------------|:------------------------------------------------------------
 `generator(order:startsAtBegin:stopsAtEnd:using:)` | Samples the Markov chain at the given order
 `generator(blending:using:)`                       | Blends several generators at fixed weights
 `generator(blending:weights:using:)`               | Blends several generators with step-varying weights
 `generator(contrasting:by:using:)`                 | Sharpens or flattens another generator’s distribution
 `generator(filtering:where:using:)`                | Removes the states that fail a predicate
 `generator(interpolating:to:over:along:using:)`    | Morphs from one generator to another over a number of steps
 `generator(looping:)`                              | Restarts another generator whenever it reaches the end
 `generator(trying:otherwise:committing:)`          | Falls back to a secondary generator when the primary yields nothing

Every generator accepts an optional random number generator; pass a
`SeededRandomNumberGenerator` to make generation reproducible.

## <a name="requirements">Requirements</a>

* iOS 18.0+ / macOS 15.0+
* Swift 6.3+ toolchain
* Swift 6 language mode

## <a name="installation">Installation</a>

### <a name="spm_installation">Swift Package Manager</a>

XestiMarkov is distributed exclusively through the [Swift Package Manager][spm].

To add XestiMarkov to a Swift package, add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eBardX/XestiMarkov.git",
             .upToNextMajor(from: "4.0.0"))
]
```

Then add `XestiMarkov` to the dependencies of any target that uses it:

```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "XestiMarkov",
                                package: "XestiMarkov")])
```

To add XestiMarkov to an Xcode project, choose **File ▸ Add Package
Dependencies…** and enter the repository URL:

```
https://github.com/eBardX/XestiMarkov.git
```

## <a name="quick_start">Quick Start</a>

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

// Inspect what was learned.
let probability = markovChain.probability(of: .state("n"),
                                          after: .states(["a"]))
let recommendedOrder = markovChain.metrics().recommendedOrder
```

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

XestiMarkov is available under [the MIT license][license].

[docc]:     https://www.swift.org/documentation/docc/
[license]:  https://github.com/eBardX/XestiMarkov/blob/main/LICENSE.md
[refdoc]:   https://eBardX.github.io/xesti-packages-docs/documentation/xestimarkov
[spm]:      https://swift.org/package-manager/
