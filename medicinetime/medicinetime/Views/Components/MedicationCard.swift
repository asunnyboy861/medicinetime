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
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(medication.displayCategory)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    // Quantity
                    Label("\(medication.quantity) \(medication.displayUnit)", systemImage: "cube.box")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Expiry
                    Label(medication.expiryStatus.label, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(medication.expiryStatus.color)
                }
            }
            
            Spacer()
            
            // Status Indicator
            Circle()
                .fill(medication.expiryStatus.color)
                .frame(width: 10, height: 10)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct MedicationCard_Previews: PreviewProvider {
    static var previews: some View {
        let medication = Medication(context: PersistenceController.preview.container.viewContext)
        medication.name = "Tylenol"
        medication.category = "Pain Relief"
        medication.quantity = 30
        medication.unit = "tablets"
        medication.expirationDate = Date().addingTimeInterval(90 * 86400)
        
        return MedicationCard(medication: medication)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
