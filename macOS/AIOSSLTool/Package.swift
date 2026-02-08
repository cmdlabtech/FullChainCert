// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIOSSLTool",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "AIOSSLTool",
            targets: ["AIOSSLTool"]
        )
    ],
    dependencies: [
        // TODO: Re-enable after setting up proper Xcode project with framework embedding
        // .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.5.0")
    ],
    targets: [
        .executableTarget(
            name: "AIOSSLTool",
            dependencies: [
                // TODO: Re-enable after setting up proper Xcode project
                // .product(name: "Sparkle", package: "Sparkle")
            ],
            path: ".",
            exclude: [
                "Info.plist",
                "AIOSSLTool.entitlements",
                "build.sh",
                "AIO SSL Tool.app",
                "AIOSSLTool.dmg",
                "AppIcon.icns",
                "icon-source.png"
            ],
            sources: [
                "AIOSSLToolApp.swift",
                "ContentView.swift",
                "ViewModels/SSLToolViewModel.swift",
                "ViewModels/UpdaterViewModel.swift",
                "Models/CSRDetails.swift",
                "Views/HomeView.swift",
                "Views/ChainBuilderView.swift",
                "Views/CSRGenerationView.swift",
                "Views/ExtractPFXView.swift",
                "Views/SettingsView.swift",
                "Utils/CertificateUtils.swift"
            ],
            resources: [
                .process("HomeIcon.png")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
