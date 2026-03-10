//
//  Medication+CoreDataClass.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData
import CloudKit
import UIKit
import SwiftUI

@objc(Medication)
public class Medication: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var barcode: String?
    @NSManaged public var category: String
    @NSManaged public var expirationDate: Date
    @NSManaged public var purchaseDate: Date
    @NSManaged public var quantity: Int16
    @NSManaged public var unit: String
    @NSManaged public var dosage: String?
    @NSManaged public var notes: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var thumbnailData: Data?
    @NSManaged public var photoReferences: NSSet?
    @NSManaged public var location: String?
    @NSManaged public var familyID: String?
    @NSManaged public var isPrivate: Bool
    @NSManaged public var isLowStock: Bool
    @NSManaged public var lowStockThreshold: Int16
    @NSManaged public var averageUsagePerMonth: Double
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var usageRecords: NSSet?
    @NSManaged public var categoryRef: Category?
    @NSManaged public var lastUpdated: Date
}

// MARK: - Computed Properties
extension Medication {
    public var isExpired: Bool {
        return expirationDate < Date()
    }
    
    public var daysUntilExpiry: Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
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
        return name
    }
    
    public func getQuantity(for member: FamilyMember) -> Int16 {
        if isPrivate && member.role != "admin" {
            return 0
        }
        return quantity
    }
}

// MARK: - ExpiryStatus Enum
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

// MARK: - Core Data Generated Code
@available(iOS 16.0, *)
extension Medication {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }
}
