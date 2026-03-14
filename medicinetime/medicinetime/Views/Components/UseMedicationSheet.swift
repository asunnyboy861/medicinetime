//
//  UseMedicationSheet.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import SwiftUI

struct UseMedicationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: MedicationViewModel
    
    let medication: Medication
    
    @State private var quantityToRemove: Int16 = 1
    @State private var notes: String = ""
    
    private var maxUsable: Int16 {
        max(0, medication.quantity)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(medication.displayName)
                                .font(.headline)
                            Text("Current: \(medication.quantity) \(medication.displayUnit)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Circle()
                            .fill(medication.expiryStatus.color)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Section("Quantity to Use") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        Stepper(value: $quantityToRemove, in: 1...max(maxUsable, 1)) {
                            Text("\(quantityToRemove) \(medication.displayUnit)")
                                .fontWeight(.medium)
                        }
                    }
                    
                    if quantityToRemove > medication.quantity {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.appWarning)
                            Text("This will result in negative stock")
                                .font(.caption)
                                .foregroundColor(.appWarning)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Reason for use", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("After Use") {
                    HStack {
                        Text("Remaining")
                        Spacer()
                        Text("\(medication.quantity - quantityToRemove) \(medication.displayUnit)")
                            .fontWeight(.medium)
                            .foregroundColor(quantityToRemove > medication.quantity ? .appError : .primary)
                    }
                    
                    if medication.quantity - quantityToRemove <= medication.lowStockThreshold {
                        Label("Will trigger low stock alert", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.appWarning)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Use Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        confirmUsage()
                    }
                    .fontWeight(.semibold)
                    .disabled(quantityToRemove <= 0)
                }
            }
        }
    }
    
    private func confirmUsage() {
        viewModel.useMedication(
            medication,
            quantity: quantityToRemove,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}

struct UseMedicationSheet_Previews: PreviewProvider {
    static var previews: some View {
        let medication = Medication(context: PersistenceController.preview.container.viewContext)
        medication.name = "Tylenol"
        medication.quantity = 30
        medication.unit = "tablets"
        
        return UseMedicationSheet(medication: medication)
            .environmentObject(MedicationViewModel(persistenceController: .preview))
    }
}
