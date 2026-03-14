//
//  WidgetDataManager.swift
//  MedCabinetWidgetExtension
//
//  Created on 2026-03-14.
//

import Foundation
import WidgetKit

// MARK: - Widget Data Model

struct WidgetMedication: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: String
    let quantity: Int
    let daysUntilExpiry: Int
    let isExpired: Bool
    let needsRestock: Bool
    let isPrescription: Bool
}

struct WidgetData: Codable {
    let medications: [WidgetMedication]
    let expiringSoonCount: Int
    let expiredCount: Int
    let lowStockCount: Int
    let lastUpdated: Date
}

// MARK: - Widget Data Manager

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.medcabinet.shared")
    private let dataKey = "widgetMedicationData"
    
    private init() {}
    
    // MARK: - Load Data for Widget
    
    func loadWidgetData() -> WidgetData? {
        guard let data = userDefaults?.data(forKey: dataKey),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return nil
        }
        return widgetData
    }
    
    // MARK: - Get Expiring Medications
    
    func getExpiringMedications(limit: Int = 5) -> [WidgetMedication] {
        guard let data = loadWidgetData() else { return [] }
        return data.medications
            .filter { !$0.isExpired }
            .sorted { $0.daysUntilExpiry < $1.daysUntilExpiry }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Get Expired Medications
    
    func getExpiredMedications() -> [WidgetMedication] {
        guard let data = loadWidgetData() else { return [] }
        return data.medications.filter { $0.isExpired }
    }
    
    // MARK: - Get Low Stock Medications
    
    func getLowStockMedications() -> [WidgetMedication] {
        guard let data = loadWidgetData() else { return [] }
        return data.medications.filter { $0.needsRestock }
    }
}

// MARK: - Color Helpers for Widget

extension WidgetMedication {
    var statusColor: String {
        if isExpired {
            return "expired"
        } else if daysUntilExpiry <= 7 {
            return "critical"
        } else if daysUntilExpiry <= 30 {
            return "warning"
        } else {
            return "good"
        }
    }
    
    var displayExpiry: String {
        if isExpired {
            return "Expired"
        } else if daysUntilExpiry == 0 {
            return "Expires today"
        } else if daysUntilExpiry == 1 {
            return "1 day left"
        } else {
            return "\(daysUntilExpiry) days left"
        }
    }
}
