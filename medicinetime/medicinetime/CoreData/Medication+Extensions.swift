//
//  Medication+Extensions.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData
import CloudKit
import UIKit
import SwiftUI

extension Medication {
    
    // MARK: - Display Properties (for UI)
    
    public var displayName: String {
        name ?? "Unknown Medication"
    }
    
    public var displayCategory: String {
        category ?? "Uncategorized"
    }
    
    public var displayUnit: String {
        unit ?? "units"
    }
    
    public var displayLocation: String {
        location ?? ""
    }
    
    public var displayNotes: String {
        notes ?? ""
    }
    
    public var safeExpirationDate: Date {
        expirationDate ?? Date().addingTimeInterval(365 * 86400)
    }
    
    // MARK: - Computed Properties
    
    public var isExpired: Bool {
        guard let date = expirationDate else { return false }
        return date < Date()
    }
    
    public var daysUntilExpiry: Int {
        guard let date = expirationDate else { return 365 }
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    public var expiryStatus: ExpiryStatus {
        let days = daysUntilExpiry
        if days < 0 { return .expired }
        if days < 30 { return .expiringSoon }
        if days < 90 { return .expiringIn3Months }
        return .good
    }
    
    public var needsRestock: Bool {
        return quantity <= lowStockThreshold
    }
    
    public var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    
    public var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    // MARK: - Family Access
    
    public func isVisibleTo(member: FamilyMember) -> Bool {
        if isPrivate {
            return member.role == "admin"
        }
        return true
    }
    
    public func getDisplayName(for member: FamilyMember) -> String {
        if isPrivate && member.role != "admin" {
            return "Private Medication"
        }
        return displayName
    }
    
    public func getQuantity(for member: FamilyMember) -> Int16 {
        if isPrivate && member.role != "admin" {
            return 0
        }
        return quantity
    }
    
    // MARK: - Prescription Properties
    
    public var isPrescription: Bool {
        get { isPrescription_ }
        set { isPrescription_ = newValue }
    }
    
    public var refillDate: Date? {
        get { refillDate_ }
        set { refillDate_ = newValue }
    }
    
    public var prescriptionNumber: String? {
        get { prescriptionNumber_ }
        set { prescriptionNumber_ = newValue }
    }
    
    public var displayPrescriptionInfo: String {
        if isPrescription {
            if let refill = refillDate {
                return "Rx • Refill: \(formatDate(refill))"
            }
            return "Rx Only"
        }
        return "OTC"
    }
    
    public var needsRefill: Bool {
        guard isPrescription, let refill = refillDate else { return false }
        return refill <= Date().addingTimeInterval(7 * 86400)
    }
    
    // MARK: - Pharmacy Information
    
    public var pharmacyName: String? {
        get { pharmacyName_ }
        set { pharmacyName_ = newValue }
    }
    
    public var pharmacyPhone: String? {
        get { pharmacyPhone_ }
        set { pharmacyPhone_ = newValue }
    }
    
    public var displayPharmacy: String {
        pharmacyName ?? "Not specified"
    }
    
    // MARK: - Insurance Information
    
    public var insuranceProvider: String? {
        get { insuranceProvider_ }
        set { insuranceProvider_ = newValue }
    }
    
    public var insurancePolicyNumber: String? {
        get { insurancePolicyNumber_ }
        set { insurancePolicyNumber_ = newValue }
    }
    
    public var copayAmount: Double {
        get { copayAmount_ }
        set { copayAmount_ = newValue }
    }
    
    public var displayCopay: String {
        if copayAmount > 0 {
            return String(format: "$%.2f", copayAmount)
        }
        return "N/A"
    }
    
    // MARK: - Helper
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Expiry Status Enum

public enum ExpiryStatus: Int, CaseIterable {
    case expired
    case expiringSoon
    case expiringIn3Months
    case good
    
    public var color: Color {
        switch self {
        case .expired: return Color(hex: "FF3B30")
        case .expiringSoon: return Color(hex: "FF9500")
        case .expiringIn3Months: return Color(hex: "FFCC00")
        case .good: return Color(hex: "34C759")
        }
    }
    
    public var label: String {
        switch self {
        case .expired: return "Expired"
        case .expiringSoon: return "Expiring Soon"
        case .expiringIn3Months: return "Expiring in 3 Months"
        case .good: return "Good"
        }
    }
}
