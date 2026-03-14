//
//  AddMedicationView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI
import CoreData

struct AddMedicationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MedicationViewModel
    
    @State private var name = ""
    @State private var selectedCategory: Category?
    @State private var quantity: Int16 = 30
    @State private var unit = "tablets"
    @State private var expirationDate = Date().addingTimeInterval(365 * 86400)
    @State private var purchaseDate = Date()
    @State private var location = ""
    @State private var notes = ""
    @State private var isPrivate = false
    @State private var lowStockThreshold: Int16 = 5
    @State private var showingScanner = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var scannedBarcode: String?
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section(header: Text("Basic Information")) {
                    TextField("Medication Name", text: $name)
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as Category?)
                        ForEach(viewModel.categories) { category in
                            Text(category.name ?? "Unknown").tag(category as Category?)
                        }
                    }
                    
                    // Barcode Scanner
                    Button(action: {
                        showingScanner = true
                    }) {
                        HStack {
                            Image(systemName: "barcode.viewfinder")
                            Text("Scan Barcode")
                        }
                    }
                }
                
                // Quantity Section
                Section(header: Text("Quantity & Stock")) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Stepper(value: $quantity, in: 0...1000) {
                            Text("\(quantity) \(unit)")
                                .foregroundColor(.primary)
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
                    
                    HStack {
                        Text("Low Stock Alert")
                        Spacer()
                        Stepper(value: $lowStockThreshold, in: 0...100) {
                            Text("Alert when ≤ \(lowStockThreshold)")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Dates Section
                Section(header: Text("Dates")) {
                    DatePicker("Expiration Date", selection: $expirationDate, in: Date()..., displayedComponents: .date)
                    
                    DatePicker("Purchase Date", selection: $purchaseDate, in: ...Date(), displayedComponents: .date)
                }
                
                // Storage Section
                Section(header: Text("Storage")) {
                    TextField("Location (e.g., Bathroom Cabinet)", text: $location)
                    
                    Toggle("Private Medication", isOn: $isPrivate)
                    
                    if isPrivate {
                        Text("This medication will only be visible to the admin.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notes Section
                Section(header: Text("Notes")) {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                }
                
                // Photo Section
                Section(header: Text("Photo")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                        
                        Button("Remove Photo", role: .destructive) {
                            selectedImage = nil
                        }
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedication()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { barcode in
                    handleScannedBarcode(barcode)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func handleScannedBarcode(_ barcode: String) {
        scannedBarcode = barcode
        let result = BarcodeService.shared.lookup(barcode: barcode)
        
        if result.confidence == .high {
            if let name = result.name {
                self.name = name
            }
            if let category = result.category {
                self.selectedCategory = viewModel.categories.first { $0.name == category }
            }
        }
    }
    
    private func saveMedication() {
        let medication = Medication(context: viewContext)
        medication.id = UUID()
        medication.name = name
        medication.category = selectedCategory?.name ?? "Other"
        medication.quantity = quantity
        medication.unit = unit
        medication.expirationDate = expirationDate
        medication.purchaseDate = purchaseDate
        medication.location = location
        medication.notes = notes
        medication.isPrivate = isPrivate
        medication.lowStockThreshold = lowStockThreshold
        medication.lastUpdated = Date()
        medication.barcode = scannedBarcode
        
        if let image = selectedImage {
            medication.imageData = image.jpegData(compressionQuality: 0.8)
            medication.thumbnailData = image.thumbnailData
        }
        
        viewModel.addMedication(medication)
        
        NotificationManager.shared.scheduleExpiryNotifications(for: medication)
        NotificationManager.shared.markMedicationAdded()
    }
}

// MARK: - Preview
struct AddMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationView(viewModel: MedicationViewModel(persistenceController: .preview))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
