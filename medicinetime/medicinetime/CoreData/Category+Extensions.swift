//
//  Category+Extensions.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData
import SwiftUI

extension Category {
    
    // MARK: - Display Properties (for UI)
    
    public var displayName: String {
        name ?? "Unknown Category"
    }
    
    public var displayIcon: String {
        guard let icon = icon, !icon.isEmpty else {
            return "pill.fill"
        }
        return icon
    }
    
    public var displayColor: Color {
        guard let color = color else {
            return .gray
        }
        return Color(hex: color)
    }
    
    // MARK: - Legacy Computed Properties (for backward compatibility)
    
    public var sfSymbol: String {
        displayIcon
    }
    
    public var uiColor: Color {
        displayColor
    }
    
    public var medicationCount: Int {
        medications?.count ?? 0
    }
    
    // MARK: - Default Data
    
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
