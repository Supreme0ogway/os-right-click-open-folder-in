// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OpenFolderIn",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "OpenFolderInShared", targets: ["OpenFolderInShared"]),
        .library(name: "OpenFolderInCore", targets: ["OpenFolderInCore"]),
        .library(name: "OpenFolderInUI", targets: ["OpenFolderInUI"]),
    ],
    targets: [
        .target(name: "OpenFolderInShared"),
        .target(
            name: "OpenFolderInCore",
            dependencies: ["OpenFolderInShared"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "OpenFolderInUI",
            dependencies: ["OpenFolderInCore"],
            resources: [.process("Resources")]
        ),

        .testTarget(name: "OpenFolderInSharedTests", dependencies: ["OpenFolderInShared"]),
        .testTarget(name: "OpenFolderInCoreTests", dependencies: ["OpenFolderInCore"]),
        .testTarget(name: "OpenFolderInUITests", dependencies: ["OpenFolderInUI"]),
    ]
)
