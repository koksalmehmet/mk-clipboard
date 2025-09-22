// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "SharedClipboardKit",
  platforms: [
    .macOS(.v14),
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "SharedClipboardKit",
      targets: ["SharedClipboardKit"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SharedClipboardKit",
      dependencies: []
    ),
    .testTarget(
      name: "SharedClipboardKitTests",
      dependencies: ["SharedClipboardKit"]
    )
  ]
)
