// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SplatNet2",
    defaultLocalization: "en",
    platforms:  [
        .iOS(.v14), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SplatNet2",
            targets: ["SplatNet2"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.3"),
        .package(url: "https://github.com/groue/CombineExpectations.git", from: "0.7.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SplatNet2",
            dependencies: ["Alamofire", "KeychainAccess"],
            resources: [.copy("Resources/coop.json"), .copy("Resources/icon.png")]
        ),
        .testTarget(
            name: "SplatNet2Tests",
            dependencies: ["SplatNet2", "CombineExpectations", "KeychainAccess"],
            resources: [.copy("Resources/coop.json"), .copy("Resources/icon.png")]
        )
    ]
)
