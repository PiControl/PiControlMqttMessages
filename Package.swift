// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

func protobufResources() throws -> [PackageDescription.Resource] {
    let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let protobufDirectory = packageDirectory
        .appendingPathComponent("Sources")
        .appendingPathComponent("pi-control-mqtt-messages")
        .appendingPathComponent("protobuf")
    let protobufFiles = try FileManager.default.contentsOfDirectory(at: protobufDirectory, includingPropertiesForKeys: [])
    
    return protobufFiles
        //.filter { $0.pathExtension == "proto" }
        .map { $0.lastPathComponent }
        .map { PackageDescription.Resource.copy("protobuf/\($0)") }
}

let package = Package(
    name: "pi-control-mqtt-messages",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PiControlMqttMessages",
            targets: ["pi-control-mqtt-messages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.28.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "pi-control-mqtt-messages",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            resources: try protobufResources(),
            plugins: [
                .plugin(name: "protoc")
            ]
        ),
        .plugin(
            name: "protoc",
            capability: .buildTool()
        )
    ]
)
