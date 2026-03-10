//
//  Color+Hex.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let (a, r, g, b) = (
            255,
            (int >> 16) & 0xFF,
            (int >> 8) & 0xFF,
            int & 0xFF
        )
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
    
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}

// MARK: - App Colors
extension Color {
    // Primary Brand Colors
    static let appPrimary = Color(hex: "007AFF") // Apple Blue
    static let appSecondary = Color(hex: "5856D6") // Purple
    
    // Semantic Colors
    static let appSuccess = Color(hex: "34C759") // Green
    static let appWarning = Color(hex: "FF9500") // Orange
    static let appError = Color(hex: "FF3B30") // Red
    
    // Background Colors
    static let appBackground = Color(hex: "F2F2F7")
    static let appCardBackground = Color(hex: "FFFFFF")
    
    // Category Colors
    static let categoryPainRelief = Color(hex: "FF6B6B")
    static let categoryColdFlu = Color(hex: "4ECDC4")
    static let categoryAllergy = Color(hex: "45B7D1")
}
