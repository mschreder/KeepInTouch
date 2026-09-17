// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeepInTouchLogic",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KeepInTouchLogic", targets: ["KeepInTouchLogic"])
    ],
    targets: [
        .target(name: "KeepInTouchLogic"),
        .testTarget(name: "KeepInTouchLogicTests", dependencies: ["KeepInTouchLogic"])
    ]
)
