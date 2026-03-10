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
                        Text(medication.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(medication.category, systemImage: "tag.fill")
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
                    
                    // Quantity and Stock
                    HStack(spacing: 20) {
                        StatBox(
                            title: "Quantity",
                            value: "\(medication.quantity) \(medication.unit)",
                            icon: "pill.fill",
                            color: medication.needsRestock ? .appError : .appSuccess
                        )
                        
                        StatBox(
                            title: "Expires In",
                            value: "\(medication.daysUntilExpiry) days",
                            icon: "clock.fill",
                            color: medication.expiryStatus.color
                        )
                    }
                    
                    // Expiry Status
                    ExpiryStatusCard(medication: medication)
                    
                    // Location
                    if let location = medication.location, !location.isEmpty {
                        InfoRow(
                            icon: "mappin.circle.fill",
                            title: "Location",
                            value: location
                        )
                    }
                    
                    // Purchase Date
                    InfoRow(
                        icon: "calendar",
                        title: "Purchased",
                        value: medication.purchaseDate.formatted(date: .long, time: .omitted)
                    )
                    
                    // Notes
                    if let notes = medication.notes, !notes.isEmpty {
                        InfoRow(
                            icon: "note.text",
                            title: "Notes",
                            value: notes,
                            multiline: true
                        )
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: {
                                medication.quantity = max(0, medication.quantity - 1)
                                viewModel.updateMedication(medication)
                            }) {
                                Label("Use 1", systemImage: "minus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.appWarning)
                            
                            Button(action: {
                                medication.quantity += 1
                                viewModel.updateMedication(medication)
                            }) {
                                Label("Add 1", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.appSuccess)
                        }
                        
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Label("Edit Medication", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        deleteMedication()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMedicationView(medication: medication)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareView(items: [medication.name])
        }
    }
    
    private func deleteMedication() {
        viewContext.delete(medication)
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - Subviews
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ExpiryStatusCard: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.appPrimary)
                
                Text("Expiry Status")
                    .font(.headline)
            }
            
            HStack {
                Circle()
                    .fill(medication.expiryStatus.color)
                    .frame(width: 12, height: 12)
                
                Text(medication.expiryStatus.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(medication.daysUntilExpiry) days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(medication.daysUntilExpiry), total: 365)
                .progressViewStyle(.linear)
                .tint(medication.expiryStatus.color)
        }
        .padding()
        .background(Color.appBackground)
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var multiline: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
        }
    }
}

// MARK: - Preview
struct MedicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let medication = Medication(context: PersistenceController.preview.container.viewContext)
        medication.name = "Tylenol"
        medication.category = "Pain Relief"
        medication.expirationDate = Date().addingTimeInterval(90 * 86400)
        medication.purchaseDate = Date().addingTimeInterval(-30 * 86400)
        medication.quantity = 25
        medication.unit = "tablets"
        medication.location = "Bathroom Cabinet"
        medication.notes = "Take with food"
        
        return MedicationDetailView(medication: medication)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
