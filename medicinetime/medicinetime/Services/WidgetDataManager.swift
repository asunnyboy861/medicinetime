//
//  WidgetDataManager.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import Foundation
import CoreData
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
    
    // MARK: - Save Data for Widget
    
    func saveWidgetData(from context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Medication.expirationDate, ascending: true)]
        
        do {
            let medications = try context.fetch(fetchRequest)
            let widgetMedications = medications.map { medication -> WidgetMedication in
                WidgetMedication(
                    id: medication.id ?? UUID(),
                    name: medication.name ?? "Unknown",
                    category: medication.category ?? "Other",
                    quantity: Int(medication.quantity),
                    daysUntilExpiry: medication.daysUntilExpiry,
                    isExpired: medication.isExpired,
                    needsRestock: medication.needsRestock,
                    isPrescription: medication.isPrescription
                )
            }
            
            let widgetData = WidgetData(
                medications: widgetMedications,
                expiringSoonCount: medications.filter { $0.daysUntilExpiry <= 30 && $0.daysUntilExpiry >= 0 }.count,
                expiredCount: medications.filter { $0.isExpired }.count,
                lowStockCount: medications.filter { $0.needsRestock }.count,
                lastUpdated: Date()
            )
            
            if let encoded = try? JSONEncoder().encode(widgetData) {
                userDefaults?.set(encoded, forKey: dataKey)
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Failed to save widget data: \(error)")
        }
    }
    
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
