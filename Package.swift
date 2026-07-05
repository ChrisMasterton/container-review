// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ContainerReview",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ContainerReview", targets: ["ContainerReview"])
    ],
    targets: [
        .executableTarget(
            name: "ContainerReview"
        )
    ]
)
