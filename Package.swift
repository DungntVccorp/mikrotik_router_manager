// swift-tools-version:3.1

import PackageDescription
//swift package -Xlinker -L/usr/local/lib generate-xcodeproj
let package = Package(
    name: "mikrotik_router_manager",
    targets: [Target(name: "SERVER", dependencies:["CORE"]),
              ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", Version(0,12,61)),
        .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git",Version(0,6,9)),
        .Package(url: "https://github.com/IBM-Swift/SwiftKueryMySQL.git",Version(0,13,1)),
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",Version(1,7,6)),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",Version(1,7,0)),
        ]
)
