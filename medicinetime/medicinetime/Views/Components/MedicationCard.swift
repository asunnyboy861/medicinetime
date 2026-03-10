//
//  MedicationCard.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

struct MedicationCard: View {
    let medication: Medication
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack(spacing: 12) {
            thumbnailView
            infoView
            Spacer()
            quantityView
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnail = medication.thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .cornerRadius(8)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appBackground)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "pill.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                )
        }
    }
    
    @ViewBuilder
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(medication.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(medication.category)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ExpiryBadge(daysUntilExpiry: medication.daysUntilExpiry)
                
                if medication.needsRestock {
                    LowStockWarning(quantity: Int(medication.quantity))
                }
            }
        }
    }
    
    @ViewBuilder
    private var quantityView: some View {
        VStack(spacing: 4) {
            Text("\(medication.quantity)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(medication.needsRestock ? .appError : .primary)
            
            Text(medication.unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ExpiryBadge: View {
    let daysUntilExpiry: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            
            Text(labelText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.1))
        .foregroundColor(badgeColor)
        .cornerRadius(6)
    }
    
    private var iconName: String {
        if daysUntilExpiry < 0 { return "xmark.circle.fill" }
        if daysUntilExpiry < 30 { return "exclamationmark.triangle.fill" }
        if daysUntilExpiry < 90 { return "clock.fill" }
        return "checkmark.circle.fill"
    }
    
    private var labelText: String {
        if daysUntilExpiry < 0 { return "Expired" }
        if daysUntilExpiry < 30 { return "\(daysUntilExpiry)d" }
        if daysUntilExpiry < 90 { return "\(daysUntilExpiry / 30)m" }
        return "Good"
    }
    
    private var badgeColor: Color {
        if daysUntilExpiry < 0 { return .appError }
        if daysUntilExpiry < 30 { return .appWarning }
        if daysUntilExpiry < 90 { return .orange }
        return .appSuccess
    }
}

struct LowStockWarning: View {
    let quantity: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
            
            Text("Low: \(quantity)")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.appError.opacity(0.1))
        .foregroundColor(.appError)
        .cornerRadius(6)
    }
}
