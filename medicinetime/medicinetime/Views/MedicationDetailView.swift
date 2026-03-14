//
//  MedicationDetailView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

struct MedicationDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: MedicationViewModel
    let medication: Medication
    
    @State private var showingEditSheet = false
    @State private var showingShareSheet = false
    @State private var quantityToRemove: Int16 = 1
    @State private var showingUseSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Image
                if let image = medication.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.appBackground)
                        .frame(height: 250)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "pill.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.secondary)
                                
                                Text("No Photo")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                // Info Card
                VStack(alignment: .leading, spacing: 16) {
                    // Name and Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text(medication.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(medication.displayCategory, systemImage: "tag.fill")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appPrimary.opacity(0.1))
                                .foregroundColor(.appPrimary)
                                .cornerRadius(16)
                            
                            if medication.isPrivate {
                                Label("Private", systemImage: "lock.fill")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.appError.opacity(0.1))
                                    .foregroundColor(.appError)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Expiry Status
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expiration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(medication.safeExpirationDate, style: .date)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Status")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(medication.expiryStatus.color)
                                    .frame(width: 10, height: 10)
                                
                                Text(medication.expiryStatus.label)
                                    .font(.headline)
                                    .foregroundColor(medication.expiryStatus.color)
                            }
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(12)
                    
                    // Days until expiry
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Days Until Expiry")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(medication.daysUntilExpiry) days")
                                .font(.headline)
                                .foregroundColor(medication.expiryStatus.color)
                        }
                        
                        ProgressView(value: Double(medication.daysUntilExpiry), total: 365)
                            .tint(medication.expiryStatus.color)
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(12)
                    
                    // Quantity
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quantity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(medication.quantity) \(medication.displayUnit)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(medication.needsRestock ? .appError : .primary)
                        }
                        
                        Spacer()
                        
                        if medication.needsRestock {
                            Label("Low Stock", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.appError)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appError.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(12)
                    
                    // Location
                    if !medication.displayLocation.isEmpty {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.secondary)
                            
                            Text(medication.displayLocation)
                                .font(.subheadline)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(12)
                    }
                    
                    // Notes
                    if !medication.displayNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(medication.displayNotes)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(12)
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: { showingUseSheet = true }) {
                            Label("Use Medication", systemImage: "minus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appPrimary)
                        
                        Button(action: { showingEditSheet = true }) {
                            Label("Edit Medication", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(role: .destructive, action: { deleteMedication() }) {
                            Label("Delete Medication", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditMedicationView(medication: medication)
        }
        .sheet(isPresented: $showingUseSheet) {
            UseMedicationSheet(medication: medication)
        }
    }
    
    private func deleteMedication() {
        viewModel.deleteMedication(medication)
        dismiss()
    }
}

// MARK: - Preview
struct MedicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let medication = Medication(context: PersistenceController.preview.container.viewContext)
        medication.name = "Tylenol"
        medication.category = "Pain Relief"
        medication.quantity = 30
        medication.unit = "tablets"
        medication.expirationDate = Date().addingTimeInterval(90 * 86400)
        medication.location = "Bathroom Cabinet"
        medication.notes = "Take with food"
        
        return NavigationView {
            MedicationDetailView(medication: medication)
                .environmentObject(MedicationViewModel(persistenceController: .preview))
        }
    }
}
