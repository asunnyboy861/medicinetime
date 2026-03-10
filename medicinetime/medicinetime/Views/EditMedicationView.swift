//
//  EditMedicationView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

struct EditMedicationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    let medication: Medication
    
    @State private var name: String
    @State private var quantity: Int16
    @State private var unit: String
    @State private var expirationDate: Date
    @State private var location: String
    @State private var notes: String
    @State private var isPrivate: Bool
    @State private var lowStockThreshold: Int16
    @State private var selectedImage: UIImage?
    
    init(medication: Medication) {
        self.medication = medication
        _name = State(initialValue: medication.name)
        _quantity = State(initialValue: medication.quantity)
        _unit = State(initialValue: medication.unit)
        _expirationDate = State(initialValue: medication.expirationDate)
        _location = State(initialValue: medication.location ?? "")
        _notes = State(initialValue: medication.notes ?? "")
        _isPrivate = State(initialValue: medication.isPrivate)
        _lowStockThreshold = State(initialValue: medication.lowStockThreshold)
        _selectedImage = State(initialValue: medication.image)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Stepper(value: $quantity, in: 0...1000) {
                            Text("\(quantity) \(unit)")
                        }
                    }
                    
                    Picker("Unit", selection: $unit) {
                        Text("tablets").tag("tablets")
                        Text("capsules").tag("capsules")
                        Text("ml").tag("ml")
                        Text("grams").tag("grams")
                        Text("pieces").tag("pieces")
                        Text("boxes").tag("boxes")
                    }
                }
                
                Section("Dates") {
                    DatePicker("Expiration Date", selection: $expirationDate, in: Date()..., displayedComponents: .date)
                }
                
                Section("Storage") {
                    TextField("Location", text: $location)
                    
                    Toggle("Private Medication", isOn: $isPrivate)
                    
                    if isPrivate {
                        Text("This medication will only be visible to the admin.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Alerts") {
                    HStack {
                        Text("Low Stock Alert")
                        Spacer()
                        Stepper(value: $lowStockThreshold, in: 0...100) {
                            Text("Alert when ≤ \(lowStockThreshold)")
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        medication.name = name
        medication.quantity = quantity
        medication.unit = unit
        medication.expirationDate = expirationDate
        medication.location = location
        medication.notes = notes
        medication.isPrivate = isPrivate
        medication.lowStockThreshold = lowStockThreshold
        medication.lastUpdated = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
}

// MARK: - Share View
struct ShareView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct EditMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        let medication = Medication(context: PersistenceController.preview.container.viewContext)
        medication.name = "Tylenol"
        medication.quantity = 30
        medication.unit = "tablets"
        medication.expirationDate = Date().addingTimeInterval(90 * 86400)
        medication.location = "Bathroom Cabinet"
        medication.notes = "Take with food"
        medication.isPrivate = false
        medication.lowStockThreshold = 5
        
        return EditMedicationView(medication: medication)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
