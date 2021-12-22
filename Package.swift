// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SplatNet2",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14), .macOS(.v10_15),
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
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/stleamist/BetterSafariView.git", from: "2.4.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.45.0"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.7.4"),
        .package(name: "CodableDictionary", url: "https://github.com/YOCKOW/SwiftCodableDictionary.git", from: "1.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SplatNet2",
            dependencies: [
                "Alamofire",
                "KeychainAccess",
                "BetterSafariView",
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "SwiftCodableDictionary", package: "CodableDictionary")
            ],
            resources: [.copy("Resources/coop.json"), .copy("Resources/icon.png")]
        ),
        .testTarget(
            name: "SplatNet2Tests",
            dependencies: ["SplatNet2", "KeychainAccess"],
            resources: [.copy("Resources/config.json")]
        ),
    ]
)
