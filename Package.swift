// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EC2macConnector",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ec2macConnector", targets: ["EC2macConnector"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0")
    ],
    targets: [
        .executableTarget(
            name: "EC2macConnector",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SotoEC2", package: "soto"),
                .product(name: "SotoEC2InstanceConnect", package: "soto"),
                .product(name: "SotoSecretsManager", package: "soto")
            ],
            path: "Sources")
    ]
)
