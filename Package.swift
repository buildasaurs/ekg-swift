import PackageDescription

let package = Package(
    name: "ekg-swift",
    dependencies: [
        .Package(url: "https://github.com/qutheory/Vapor.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/czechboy0/Redbird.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/vapor-stencil.git", majorVersion: 0, minor: 2)
    ]
)
