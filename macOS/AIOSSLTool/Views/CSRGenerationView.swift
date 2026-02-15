//
//  CSRGenerationView.swift
//  AIO SSL Tool
//

import SwiftUI

struct CSRGenerationView: View {
    @ObservedObject var viewModel: SSLToolViewModel
    
    @State private var commonName = ""
    @State private var country = ""
    @State private var state = ""
    @State private var locality = ""
    @State private var organization = ""
    @State private var organizationalUnit = ""
    @State private var email = ""
    @State private var sansText = ""
    @State private var keySize = "2048"
    @State private var keyPassword = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("CSR Generator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Create Certificate Signing Requests and Private Keys")
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(.thinMaterial)
            
            ScrollView {
                if viewModel.saveDirectory == nil {
                     ContentUnavailableView("Save Location Required", systemImage: "folder.badge.plus", description: Text("Please select a save location in the Chain Builder tool first."))
                        .padding(.top, 50)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Main Form
                        GroupBox(label: Label("Certificate Identity", systemImage: "person.text.rectangle")) {
                            VStack(spacing: 12) {
                                FormField(label: "Common Name (CN)", placeholder: "example.com", text: $commonName)
                                FormField(label: "Organization (O)", placeholder: "My Company LLC", text: $organization)
                                FormField(label: "Department (OU)", placeholder: "IT", text: $organizationalUnit)
                                FormField(label: "State/Province (ST)", placeholder: "California", text: $state)
                                FormField(label: "Locality (L)", placeholder: "San Francisco", text: $locality)
                                FormField(label: "Country Code (C)", placeholder: "US", text: $country)
                                FormField(label: "Email Address", placeholder: "admin@example.com", text: $email)
                            }
                            .padding()
                        }
                        
                        GroupBox(label: Label("Alternative Names (SANs)", systemImage: "globe")) {
                            VStack(alignment: .leading) {
                                Text("Enter domain names, one per line:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: $sansText)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minHeight: 100)
                                    .overlay(Rectangle().stroke(Color.secondary.opacity(0.2)))
                            }
                            .padding()
                        }
                        
                        GroupBox(label: Label("Security Options", systemImage: "lock.shield")) {
                            HStack(spacing: 40) {
                                Picker("Key Size", selection: $keySize) {
                                    Text("2048 bits").tag("2048")
                                    Text("3072 bits").tag("3072")
                                    Text("4096 bits").tag("4096")
                                }
                                .frame(width: 250)
                                
                                SecureField("Key Password (Optional)", text: $keyPassword)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding()
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: generateCSR) {
                                Label("Generate CSR & Key", systemImage: "doc.check")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(commonName.isEmpty)
                        }
                        .padding(.top)
                        
                    }
                    .padding()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showingSuccess) {
            Button("OK") { }
        } message: {
            Text(viewModel.successMessage)
        }
    }
    
    private func generateCSR() {
        let sans = sansText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let details = CSRDetails(
            commonName: commonName,
            country: country,
            state: state,
            locality: locality,
            organization: organization,
            organizationalUnit: organizationalUnit,
            email: email,
            sans: sans,
            keySize: Int(keySize) ?? 2048,
            keyPassword: keyPassword.isEmpty ? nil : keyPassword
        )
        
        viewModel.generateCSR(details: details)
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .frame(width: 160, alignment: .leading)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}
