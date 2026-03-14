//
//  MedicationUsage+Extensions.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import Foundation

// MARK: - Display Properties for UI
extension MedicationUsage {

    /// Formatted date string for display (e.g., "Mar 14, 2026, 2:30 PM")
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date ?? Date())
    }

    /// Formatted quantity string with minus sign (e.g., "-2")
    var displayQuantity: String {
        return "-\(quantity)"
    }

    /// User who used the medication, defaults to "Me" if not specified
    var displayUsedBy: String {
        return usedBy ?? "Me"
    }

    /// Relative time description (e.g., "2 hours ago", "Yesterday")
    var relativeTimeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date ?? Date(), relativeTo: Date())
    }
}
