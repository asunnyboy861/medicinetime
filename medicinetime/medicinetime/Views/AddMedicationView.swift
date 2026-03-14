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
    @State private var showAutoFillConfirmation = false
    @State private var showManualEntryTip = false
    @State private var lastScannedMedicationName: String?
    
    // MARK: - Prescription & Pharmacy Fields
    @State private var isPrescription = false
    @State private var prescriptionNumber = ""
    @State private var refillDate = Date().addingTimeInterval(30 * 86400)
    @State private var pharmacyName = ""
    @State private var pharmacyPhone = ""
    @State private var insuranceProvider = ""
    @State private var insurancePolicyNumber = ""
    @State private var copayAmount: Double = 0.0
    
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
                
                // Prescription Section
                Section(header: Text("Prescription Information")) {
                    Toggle("Prescription Medication (Rx)", isOn: $isPrescription)
                    
                    if isPrescription {
                        TextField("Prescription Number (Optional)", text: $prescriptionNumber)
                        
                        DatePicker("Refill Date", selection: $refillDate, displayedComponents: .date)
                        
                        if refillDate <= Date().addingTimeInterval(7 * 86400) {
                            Label("Refill needed soon", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.appWarning)
                                .font(.caption)
                        }
                    }
                }
                
                // Pharmacy Section
                Section(header: Text("Pharmacy")) {
                    TextField("Pharmacy Name (e.g., CVS, Walgreens)", text: $pharmacyName)
                    TextField("Phone Number", text: $pharmacyPhone)
                        .keyboardType(.phonePad)
                }
                
                // Insurance Section
                Section(header: Text("Insurance")) {
                    TextField("Insurance Provider", text: $insuranceProvider)
                    TextField("Policy Number", text: $insurancePolicyNumber)
                    
                    HStack {
                        Text("Copay Amount")
                        Spacer()
                        TextField("$0.00", value: $copayAmount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
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
            .alert("Medication Recognized", isPresented: $showAutoFillConfirmation) {
                Button("OK, I'll Review") { }
            } message: {
                if let medName = lastScannedMedicationName {
                    Text("We've auto-filled details for \(medName). Please review and confirm before saving.")
                } else {
                    Text("We've automatically filled in the medication details. Please review and confirm before saving.")
                }
            }
            .alert("Barcode Not Found", isPresented: $showManualEntryTip) {
                Button("Enter Manually") { }
            } message: {
                Text("This barcode isn't in our database. Please enter the medication details manually.")
            }
        }
    }

    private func handleScannedBarcode(_ barcode: String) {
        scannedBarcode = barcode
        let result = BarcodeService.shared.lookup(barcode: barcode)

        switch result.confidence {
        case .high:
            // Auto-fill all available fields
            if let medName = result.name {
                self.name = medName
                self.lastScannedMedicationName = medName
            }
            if let categoryName = result.category {
                self.selectedCategory = viewModel.categories.first { $0.name == categoryName }
            }
            // Show confirmation to user
            showAutoFillConfirmation = true
        case .medium, .low:
            // No match or low confidence, prompt manual entry
            showManualEntryTip = true
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
        
        // Prescription & Pharmacy Information
        medication.isPrescription = isPrescription
        medication.prescriptionNumber = prescriptionNumber.isEmpty ? nil : prescriptionNumber
        medication.refillDate = isPrescription ? refillDate : nil
        medication.pharmacyName = pharmacyName.isEmpty ? nil : pharmacyName
        medication.pharmacyPhone = pharmacyPhone.isEmpty ? nil : pharmacyPhone
        medication.insuranceProvider = insuranceProvider.isEmpty ? nil : insuranceProvider
        medication.insurancePolicyNumber = insurancePolicyNumber.isEmpty ? nil : insurancePolicyNumber
        medication.copayAmount = copayAmount
        
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
