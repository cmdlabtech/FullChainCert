//
//  UpdaterViewModel.swift
//  AIO SSL Tool
//
//  Auto-Update Management using Sparkle Framework
//

import SwiftUI
// TODO: Re-enable after fixing framework embedding
// import Sparkle

final class UpdaterViewModel: ObservableObject {
    @Published var canCheckForUpdates = false
    @Published var lastUpdateCheckDate: Date?
    @Published var automaticUpdateChecks = true
    @Published var automaticDownload = false
    
    // TODO: Re-enable after fixing framework embedding
    // private let updaterController: SPUStandardUpdaterController
    
    init() {
        // TODO: Re-enable Sparkle after fixing framework embedding
        /*
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        // Observe updater state
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
        */
        
        // Load preferences
        loadPreferences()
    }
    
    // MARK: - Update Actions
    
    func checkForUpdates() {
        // TODO: Re-enable after fixing framework embedding
        // updaterController.checkForUpdates(nil)
        lastUpdateCheckDate = Date()
        savePreferences()
    }
    
    func checkForUpdatesInBackground() {
        if automaticUpdateChecks {
            // TODO: Re-enable after fixing framework embedding
            // updaterController.updater.checkForUpdatesInBackground()
            lastUpdateCheckDate = Date()
            savePreferences()
        }
    }
    
    // MARK: - Settings
    
    func toggleAutomaticUpdates() {
        automaticUpdateChecks.toggle()
        // TODO: Re-enable after fixing framework embedding
        // updaterController.updater.automaticallyChecksForUpdates = automaticUpdateChecks
        savePreferences()
    }
    
    func toggleAutomaticDownload() {
        automaticDownload.toggle()
        // TODO: Re-enable after fixing framework embedding
        // updaterController.updater.automaticallyDownloadsUpdates = automaticDownload
        savePreferences()
    }
    
    // MARK: - Persistence
    
    private func loadPreferences() {
        automaticUpdateChecks = UserDefaults.standard.bool(forKey: "AutomaticUpdateChecks")
        automaticDownload = UserDefaults.standard.bool(forKey: "AutomaticDownload")
        
        // TODO: Re-enable after fixing framework embedding
        // Apply to updater
        // updaterController.updater.automaticallyChecksForUpdates = automaticUpdateChecks
        // updaterController.updater.automaticallyDownloadsUpdates = automaticDownload
        
        if let lastCheck = UserDefaults.standard.object(forKey: "LastUpdateCheckDate") as? Date {
            lastUpdateCheckDate = lastCheck
        }
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(automaticUpdateChecks, forKey: "AutomaticUpdateChecks")
        UserDefaults.standard.set(automaticDownload, forKey: "AutomaticDownload")
        
        if let date = lastUpdateCheckDate {
            UserDefaults.standard.set(date, forKey: "LastUpdateCheckDate")
        }
    }
    
    // MARK: - Version Info
    
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var formattedLastCheckDate: String {
        guard let date = lastUpdateCheckDate else {
            return "Never"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
