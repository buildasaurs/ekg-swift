import PackageDescription

let package = Package(
    name: "ekg-swift",
    dependencies: [
        .Package(url: "https://github.com/kylef/Curassow.git", majorVersion: 0, minor: 3)
    ]
)
