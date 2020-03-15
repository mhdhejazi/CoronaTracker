// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CoronaData",
    platforms: [.iOS(.v10), .macOS(.v10_15)],
    products: [
        .library(
            name: "CoronaData",
            targets: ["CoronaData"]),
    ],
    dependencies: [
		.package(url: "https://github.com/saoudrizwan/Disk", from: "0.6.4"),
		.package(url: "https://github.com/yaslab/CSV.swift", from: "2.4.3")
    ],
    targets: [
        .target(
            name: "CoronaData",
            dependencies: [.product(name: "Disk"),
                           .product(name: "CSV")]),
    ]
)
