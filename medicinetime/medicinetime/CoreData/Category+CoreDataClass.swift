//
//  Category+CoreDataClass.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData
import SwiftUI

@objc(Category)
public class Category: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String // SF Symbol
    @NSManaged public var color: String // Hex
    @NSManaged public var sortOrder: Int16
    @NSManaged public var medications: NSSet?
}

// MARK: - Computed Properties
extension Category {
    public var sfSymbol: String {
        return icon.isEmpty ? "pill.fill" : icon
    }
    
    public var uiColor: Color {
        return Color(hex: color)
    }
    
    public var medicationCount: Int {
        return medications?.count ?? 0
    }
}

// MARK: - Default Categories
extension Category {
    public static let defaultCategories: [(name: String, icon: String, color: String)] = [
        ("Pain Relief", "pill.fill", "FF6B6B"),
        ("Cold & Flu", "thermometer.sun.fill", "4ECDC4"),
        ("Allergy", "wind", "45B7D1"),
        ("Digestive", "drop.fill", "96CEB4"),
        ("First Aid", "cross.fill", "FFEEAD"),
        ("Vitamins", "heart.fill", "FF9FF3"),
        ("Skin Care", "hand.raised.fill", "D4A5A5"),
        ("Eye Care", "eye.fill", "9B59B6"),
        ("Other", "ellipsis", "95A5A6")
    ]
    
    public static let sensitiveCategories: [String] = [
        "Contraceptives",
        "Antidepressants",
        "Sexual Health",
        "Addiction Treatment",
        "HIV/AIDS Medications",
        "Psychiatric Medications"
    ]
    
    public static func isSensitiveCategory(_ name: String) -> Bool {
        return sensitiveCategories.contains {
            name.localizedCaseInsensitiveContains($0)
        }
    }
}

// MARK: - Core Data Generated Code
@available(iOS 16.0, *)
extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
}
