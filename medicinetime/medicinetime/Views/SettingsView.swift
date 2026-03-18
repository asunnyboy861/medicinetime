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
    @State private var darkModeEnabled = false
    @State private var units = "tablets"
    
    var body: some View {
        NavigationStack {
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
                    
                    if let privacyURL = URL(string: "https://medicinetime-privacy.zzoutuo.com") {
                        Link("Privacy Policy", destination: privacyURL)
                    }
                    if let termsURL = URL(string: "https://medicinetime-support.zzoutuo.com") {
                        Link("Terms of Service", destination: termsURL)
                    }
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
    @EnvironmentObject private var viewModel: MedicationViewModel
    @State private var exportFormat: ExportFormat = .csv
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var errorMessage: String?
    @State private var showError = false

    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case pdf = "PDF"
    }

    var body: some View {
        List {
            Section("Export Format") {
                Picker("Format", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Preview") {
                HStack {
                    Text("Medications to Export")
                    Spacer()
                    Text("\(viewModel.medications.count)")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                }

                if viewModel.medications.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.appWarning)
                        Text("No medications to export")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.appSuccess)
                        Text("Ready to export")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }

            Section {
                Button(action: exportData) {
                    HStack {
                        Spacer()
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export \(exportFormat.rawValue)")
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.medications.isEmpty || isExporting)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Export Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An error occurred during export. Please try again.")
        }
    }

    private func exportData() {
        isExporting = true

        Task {
            let url: URL?

            switch exportFormat {
            case .csv:
                url = ExportService.shared.exportToCSV(
                    medications: viewModel.medications
                )
            case .pdf:
                url = ExportService.shared.exportToPDF(
                    medications: viewModel.medications
                )
            }

            await MainActor.run {
                isExporting = false

                if let url = url {
                    exportURL = url
                    showShareSheet = true
                } else {
                    errorMessage = "Failed to generate export file"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
                    FeedbackView()
                }
                
                if let supportURL = URL(string: "https://medicinetime-support.zzoutuo.com") {
                    Link("Online Support Center", destination: supportURL)
                }
            }
            
            Section("Legal") {
                if let privacyURL = URL(string: "https://medicinetime-privacy.zzoutuo.com") {
                    Link("Privacy Policy", destination: privacyURL)
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
