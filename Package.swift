// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "MoonSecDeobf",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MoonSecDeobf", targets: ["MoonSecDeobf"])
    ],
    targets: [
        .target(name: "MoonSecDeobf", path: ".")
    ]
)
