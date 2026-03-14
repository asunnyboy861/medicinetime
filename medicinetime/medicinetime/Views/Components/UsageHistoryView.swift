//
//  UsageHistoryView.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import SwiftUI

struct UsageHistoryView: View {
    let medication: Medication
    @EnvironmentObject private var viewModel: MedicationViewModel

    private var usageHistory: [MedicationUsage] {
        viewModel.fetchUsageHistory(for: medication)
    }

    var body: some View {
        List {
            if usageHistory.isEmpty {
                EmptyStateView(
                    title: "No Usage History",
                    message: "This medication hasn't been used yet. Use the 'Use Medication' button to record usage.",
                    icon: "clock.arrow.circlepath"
                )
            } else {
                Section {
                    ForEach(usageHistory, id: \.id) { usage in
                        UsageRecordRow(usage: usage)
                    }
                } header: {
                    Text("Recent Usage")
                } footer: {
                    Text("Showing \(usageHistory.count) record(s)")
                }
            }
        }
        .navigationTitle("Usage History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UsageRecordRow: View {
    let usage: MedicationUsage

    var body: some View {
        HStack(spacing: 12) {
            // Date and user info
            VStack(alignment: .leading, spacing: 4) {
                Text(usage.displayDate)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(usage.displayUsedBy)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Notes if available
                if let notes = usage.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }

            Spacer()

            // Quantity used
            VStack(alignment: .trailing, spacing: 2) {
                Text(usage.displayQuantity)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appError)

                Text("used")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct UsageHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let medication = Medication(context: context)
        medication.id = UUID()
        medication.name = "Tylenol"

        // Create sample usage records
        let usage1 = MedicationUsage(context: context)
        usage1.id = UUID()
        usage1.medicationID = medication.id
        usage1.date = Date()
        usage1.quantity = 2
        usage1.notes = "Headache"
        usage1.medication = medication

        let usage2 = MedicationUsage(context: context)
        usage2.id = UUID()
        usage2.medicationID = medication.id
        usage2.date = Date().addingTimeInterval(-86400)
        usage2.quantity = 1
        usage2.medication = medication

        return NavigationView {
            UsageHistoryView(medication: medication)
                .environmentObject(MedicationViewModel(persistenceController: .preview))
        }
    }
}
