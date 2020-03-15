// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoronaTrackerData",
    platforms: [.iOS(.v10), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CoronaTrackerData",
            targets: ["CoronaTrackerData"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/saoudrizwan/Disk.git", .upToNextMinor(from: "0.6.4")),
        .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.4.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CoronaTrackerData",
            dependencies: [.product(name: "Disk"),
                           .product(name: "CSV")]),
        .testTarget(
            name: "CoronaTrackerDataTests",
            dependencies: ["CoronaTrackerData"]),
    ]
)
