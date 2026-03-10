//
//  SettingsView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationEnabled = true
    @State private var lowStockAlertEnabled = true
    @State private var expiryAlertEnabled = true
    @State private var backupEnabled = true
    @State private var darkModeEnabled = false
    @State private var units = "tablets"
    
    var body: some View {
        NavigationView {
            Form {
                // Notifications Section
                Section("Notifications") {
                    Toggle("Expiry Alerts", isOn: $expiryAlertEnabled)
                    Toggle("Low Stock Alerts", isOn: $lowStockAlertEnabled)
                }
                
                // Privacy Section
                Section("Privacy") {
                    Toggle("Private Medications", isOn: $notificationEnabled)
                    
                    NavigationLink("Sensitive Categories") {
                        SensitiveCategoriesView()
                    }
                }
                
                // Backup & Sync Section
                Section("Backup & Sync") {
                    Toggle("iCloud Backup", isOn: $backupEnabled)
                    
                    NavigationLink("Export Data") {
                        ExportDataView()
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    
                    Picker("Default Unit", selection: $units) {
                        Text("tablets").tag("tablets")
                        Text("capsules").tag("capsules")
                        Text("ml").tag("ml")
                        Text("grams").tag("grams")
                        Text("pieces").tag("pieces")
                        Text("boxes").tag("boxes")
                    }
                }
                
                // About Section
                Section("About") {
                    NavigationLink("Version") {
                        VersionView()
                    }
                    
                    NavigationLink("Help & Support") {
                        HelpView()
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                
                // Danger Zone Section
                Section("Danger Zone") {
                    Button("Clear All Data", role: .destructive) {
                        // TODO: Confirm and clear data
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SensitiveCategoriesView: View {
    var body: some View {
        List {
            ForEach(Category.sensitiveCategories, id: \.self) { category in
                HStack {
                    Text(category)
                    Spacer()
                    Image(systemName: "lock.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Sensitive Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExportDataView: View {
    @State private var exportFormat = "CSV"
    @State private var exportMethod = "Email"
    
    var body: some View {
        List {
            Section("Format") {
                Picker("Format", selection: $exportFormat) {
                    Text("CSV").tag("CSV")
                    Text("PDF").tag("PDF")
                    Text("JSON").tag("JSON")
                }
                .pickerStyle(.segmented)
            }
            
            Section("Method") {
                Picker("Method", selection: $exportMethod) {
                    Text("Email").tag("Email")
                    Text("iCloud").tag("iCloud")
                    Text("AirDrop").tag("AirDrop")
                }
            }
            
            Section {
                Button("Export Now") {
                    // TODO: Export functionality
                }
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VersionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("AppIcon")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("MedCabinet")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("© 2026 MedCabinet Team")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                NavigationLink("How to Add Medications") {
                    Text("Instructions for adding medications")
                        .padding()
                }
                
                NavigationLink("Setting Up Expiry Alerts") {
                    Text("How to configure expiry notifications")
                        .padding()
                }
            }
            
            Section("Troubleshooting") {
                NavigationLink("Common Issues") {
                    Text("Solutions to common problems")
                        .padding()
                }
                
                NavigationLink("Contact Support") {
                    Text("Get help from our support team")
                        .padding()
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
