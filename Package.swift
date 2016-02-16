import PackageDescription

let package = Package(
    name: "ekg-swift",
    dependencies: [
        .Package(url: "https://github.com/kylef/Curassow.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/nestproject/Frank.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/czechboy0/Redbird.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0)
        // .Package(url: "https://github.com/apple/swift-corelibs-xctest.git", majorVersion: 0)
    ]
)
