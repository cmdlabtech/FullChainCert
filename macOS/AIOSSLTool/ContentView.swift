//
//  ContentView.swift
//  AIO SSL Tool
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SSLToolViewModel()
    @State private var selectedTool: Tool? = .chainBuilder
    
    enum Tool: String, CaseIterable, Identifiable {
        case chainBuilder = "Chain Builder"
        case csrGenerator = "CSR Generator"
        case keyExtractor = "Key Extractor"
        case settings = "Settings"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .chainBuilder: return "link.circle.fill"
            case .csrGenerator: return "doc.badge.plus"
            case .keyExtractor: return "key.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(Tool.allCases, selection: $selectedTool) { tool in
                NavigationLink(value: tool) {
                    Label(tool.rawValue, systemImage: tool.icon)
                        .padding(.vertical, 8)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
            .listStyle(.sidebar)
            .navigationTitle("SSL Suite")
        } detail: {
            ZStack {
                // Background Gradient
                LinearGradient(colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.controlBackgroundColor)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

                if let tool = selectedTool {
                    switch tool {
                    case .chainBuilder:
                        ChainBuilderView(viewModel: viewModel)
                    case .csrGenerator:
                        CSRGenerationView(viewModel: viewModel)
                    case .keyExtractor:
                        ExtractPFXView(viewModel: viewModel)
                    case .settings:
                        SettingsView()
                    }
                } else {
                    ContentUnavailableView("Select a Tool", systemImage: "wrench.and.screwdriver")
                }
            }
        }
        .preferredColorScheme(.dark)
        .frame(minWidth: 900, minHeight: 600)
    }
}
