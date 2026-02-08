//
//  AIOSSLToolApp.swift
//  CMDLAB AIO SSL Tool
//
//  Modern macOS SSL Certificate Management Tool
//

import SwiftUI

@main
struct AIOSSLToolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
        }
    }
}
