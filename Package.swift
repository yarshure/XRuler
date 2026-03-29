// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "XRuler",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "XRuler",
            type: .dynamic,
            targets: ["XRuler"]
        ),
    ],
    dependencies: [
        .package(path: "../AxLogger/AxLogger"),
        .package(path: "../XFoundation"),
        .package(path: "../DarwinCore"),
        .package(path: "../Xcon"),
    ],
    targets: [
        .binaryTarget(
            name: "MMDB",
            path: "../../Build/iOS_Mac/MMDB.xcframework"
        ),
        .target(
            name: "XRuler",
            dependencies: [
                .product(name: "AxLogger", package: "AxLogger"),
                .product(name: "XFoundation", package: "XFoundation"),
                .product(name: "DarwinCore", package: "DarwinCore"),
                .product(name: "Xcon", package: "Xcon"),
                "MMDB",
            ],
            path: "XRuler",
            exclude: [
                "Info.plist",
                "XRuler.h",
                "mac.xcconfig",
            ],
            resources: [
                .copy("CNIP.bin"),
                .copy("Default.conf"),
            ]
        ),
    ]
)
