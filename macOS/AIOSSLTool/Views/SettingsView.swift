//
//  SettingsView.swift
//  AIO SSL Tool
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings & About")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(.thinMaterial)
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .font(.system(size: 80))
                            .shadow(radius: 10)
                        
                        Text("AIO SSL Suite")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 6.0")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                    }
                    .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        GroupBox(label: Label("About", systemImage: "info.circle")) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("A modern, native macOS application for SSL certificate management.")
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Divider()
                                
                                HStack {
                                    Text("License")
                                    Spacer()
                                    Text("MIT")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Developer")
                                    Spacer()
                                    Text("CMDLAB")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                        }
                        
                        GroupBox(label: Label("System", systemImage: "cpu")) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Security Framework")
                                    Spacer()
                                    Label("Native", systemImage: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Text("Sandboxed")
                                    Spacer()
                                    Label("Yes", systemImage: "lock.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                    .frame(maxWidth: 600)
                    
                    Spacer()
                    
                    Text("© 2026 CMDLAB. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
        }
    }
}
