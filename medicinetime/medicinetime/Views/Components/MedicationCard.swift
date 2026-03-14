//
//  MedicationCard.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

struct MedicationCard: View {
    let medication: Medication
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon or Image
            medicationIcon
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                // Name and Location
                HStack {
                    Text(medication.displayName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if !medication.displayLocation.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(medication.displayLocation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Category
                Text(medication.displayCategory)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Details row
                HStack(spacing: 12) {
                    // Quantity with color coding
                    Label(
                        "\(medication.quantity) \(medication.displayUnit)",
                        systemImage: "cube.box"
                    )
                    .font(.caption)
                    .foregroundColor(medication.needsRestock ? .appError : .secondary)
                    
                    // Expiry countdown
                    expiryLabel
                }
            }
            
            Spacer()
            
            // Status Indicator
            statusIndicator
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Subviews
    
    private var medicationIcon: some View {
        Group {
            if let image = medication.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(medication.expiryStatus.color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "pill.fill")
                        .font(.title2)
                        .foregroundColor(medication.expiryStatus.color)
                }
            }
        }
    }
    
    private var expiryLabel: some View {
        let (text, color) = expiryInfo
        
        return Label(
            text,
            systemImage: "clock"
        )
        .font(.caption)
        .foregroundColor(color)
    }
    
    private var statusIndicator: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(medication.expiryStatus.color)
                .frame(width: 10, height: 10)
            
            // Show warning for low stock
            if medication.needsRestock {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundColor(.appWarning)
            }
        }
    }
    
    // MARK: - Helper
    
    private var expiryInfo: (text: String, color: Color) {
        let days = medication.daysUntilExpiry
        
        if days < 0 {
            return ("Expired", .appError)
        } else if days == 0 {
            return ("Expires today", .appError)
        } else if days == 1 {
            return ("1 day left", .appError)
        } else if days <= 7 {
            return ("\(days) days left", .appWarning)
        } else if days <= 30 {
            return ("\(days) days left", .appWarning)
        } else {
            return ("Good until \(formatDate(medication.safeExpirationDate))", .secondary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct MedicationCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state
            let normalMed = createMedication(name: "Tylenol", days: 90, quantity: 30)
            MedicationCard(medication: normalMed)
                .previewDisplayName("Normal")
            
            // Expiring soon
            let expiringMed = createMedication(name: "Advil", days: 5, quantity: 10)
            MedicationCard(medication: expiringMed)
                .previewDisplayName("Expiring Soon")
            
            // Low stock
            let lowStockMed = createMedication(name: "Vitamin D", days: 180, quantity: 2, threshold: 5)
            MedicationCard(medication: lowStockMed)
                .previewDisplayName("Low Stock")
            
            // Expired
            let expiredMed = createMedication(name: "Old Med", days: -5, quantity: 5)
            MedicationCard(medication: expiredMed)
                .previewDisplayName("Expired")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
    
    static func createMedication(name: String, days: Int, quantity: Int16, threshold: Int16 = 5) -> Medication {
        let medication = Medication(context: PersistenceController.preview.container.viewContext)
        medication.name = name
        medication.category = "Pain Relief"
        medication.quantity = quantity
        medication.unit = "tablets"
        medication.expirationDate = Date().addingTimeInterval(TimeInterval(days * 86400))
        medication.location = "Bathroom Cabinet"
        medication.lowStockThreshold = threshold
        return medication
    }
}
