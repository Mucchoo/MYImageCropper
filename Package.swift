// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MYImageCropper",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MYImageCropper",
            targets: ["MYImageCropper"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MYImageCropper",
            dependencies: []),
        .testTarget(
            name: "MYImageCropperTests",
            dependencies: ["MYImageCropper"]),
    ]
)
