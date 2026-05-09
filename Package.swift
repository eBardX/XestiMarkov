// swift-tools-version: 6.2

// © 2026 John Gary Pusey (see LICENSE.md)

import PackageDescription

let swiftSettings: [SwiftSetting] = [.defaultIsolation(nil),
                                     .enableUpcomingFeature("ExistentialAny"),
                                     .enableUpcomingFeature("ImmutableWeakCaptures"),
                                     .enableUpcomingFeature("InferIsolatedConformances"),
                                     .enableUpcomingFeature("InternalImportsByDefault"),
                                     .enableUpcomingFeature("MemberImportVisibility"),
                                     .enableUpcomingFeature("NonisolatedNonsendingByDefault")]

let package = Package(name: "XestiMarkov",
                      platforms: [.iOS(.v18),
                                  .macOS(.v15)],
                      products: [.library(name: "XestiMarkov",
                                          targets: ["XestiMarkov"])],
                      dependencies: [.package(url: "https://github.com/eBardX/XestiTools.git",
                                              .upToNextMajor(from: "7.4.0"))],
                      targets: [.target(name: "XestiMarkov",
                                        dependencies: [.product(name: "XestiTools",
                                                                package: "XestiTools")],
                                        swiftSettings: swiftSettings),
                                .testTarget(name: "XestiMarkovTests",
                                            dependencies: [.target(name: "XestiMarkov")],
                                            swiftSettings: swiftSettings)],
                      swiftLanguageModes: [.v6])
