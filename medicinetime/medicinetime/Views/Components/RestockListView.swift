//
//  RestockListView.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import SwiftUI

struct RestockListView: View {
    @ObservedObject var viewModel: MedicationViewModel
    @State private var selectedItems: Set<UUID> = []
    
    private var restockItems: [Medication] {
        viewModel.medications.filter { $0.needsRestock }
    }
    
    var body: some View {
        NavigationView {
            List {
                if restockItems.isEmpty {
                    EmptyStateView(
                        title: "All Stocked Up!",
                        message: "No medications need restocking",
                        icon: "checkmark.circle.fill"
                    )
                } else {
                    ForEach(restockItems) { medication in
                        RestockItemRow(
                            medication: medication,
                            isSelected: selectedItems.contains(medication.id ?? UUID())
                        ) {
                            toggleSelection(medication)
                        }
                    }
                }
            }
            .navigationTitle("Restock List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(selectedItems.count == restockItems.count ? "Deselect All" : "Select All") {
                        if selectedItems.count == restockItems.count {
                            selectedItems.removeAll()
                        } else {
                            selectedItems = Set(restockItems.compactMap { $0.id })
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { copyToClipboard() }) {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
        }
    }
    
    private func toggleSelection(_ medication: Medication) {
        guard let id = medication.id else { return }
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }
    
    private func copyToClipboard() {
        let items = restockItems.filter { selectedItems.contains($0.id ?? UUID()) }
        let text = items.map { "- \($0.displayName) (\($0.quantity) \($0.displayUnit) remaining)" }
            .joined(separator: "\n")
        
        let fullText = "🛒 Restock List\n\n\(text)"
        UIPasteboard.general.string = fullText
    }
}

struct RestockItemRow: View {
    let medication: Medication
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .appPrimary : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("\(medication.quantity) left", systemImage: "cube.box")
                            .font(.caption)
                            .foregroundColor(.appWarning)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Threshold: \(medication.lowStockThreshold)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct RestockListView_Previews: PreviewProvider {
    static var previews: some View {
        RestockListView(viewModel: MedicationViewModel(persistenceController: .preview))
    }
}
