//
//  MedicationIntents.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData
import AppIntents

// MARK: - Query Medication Intent
@available(iOS 16.0, *)
struct QueryMedicationIntent: AppIntent {
    static var title: LocalizedStringResource = "Query Medication"
    static var description = IntentDescription("Query if you have a specific medication")
    
    @Parameter(title: "Medication Name")
    var medicationName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Do I have \(\.$medicationName)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let medications = fetchMedications(name: medicationName)
        
        if let medication = medications.first {
            let name = medication.name ?? "Medication"
            let unit = medication.unit ?? "units"
            
            if medication.quantity <= 0 {
                return .result(dialog: "You have \(name) but you're out of it.")
            } else if medication.daysUntilExpiry < 0 {
                return .result(dialog: "You have \(name), but it has expired.")
            } else if medication.needsRestock {
                return .result(dialog: "You have \(name). Only \(medication.quantity) \(unit) left - you should restock soon!")
            } else {
                return .result(dialog: "Yes, you have \(name). \(medication.quantity) \(unit) in your cabinet.")
            }
        } else {
            return .result(dialog: "You don't have \(medicationName) in your cabinet.")
        }
    }
    
    private func fetchMedications(name: String) -> [Medication] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
        request.fetchLimit = 5
        
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
}

// MARK: - Expiring Soon Intent
@available(iOS 16.0, *)
struct ExpiringSoonIntent: AppIntent {
    static var title: LocalizedStringResource = "Expiring Medications"
    static var description = IntentDescription("List medications expiring soon")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let medications = fetchExpiringMedications()
        
        if medications.isEmpty {
            return .result(dialog: "Good news! No medications are expiring soon.")
        } else {
            let names = medications.compactMap { $0.name }.joined(separator: ", ")
            let count = medications.count
            return .result(dialog: "You have \(count) medication\(count == 1 ? "" : "s") expiring soon: \(names)")
        }
    }
    
    private func fetchExpiringMedications() -> [Medication] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        request.predicate = NSPredicate(format: "expirationDate <= %@ AND expirationDate >= %@", thirtyDaysFromNow as CVarArg, Date() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "expirationDate", ascending: true)]
        request.fetchLimit = 5
        
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
}

// MARK: - Low Stock Intent
@available(iOS 16.0, *)
struct LowStockIntent: AppIntent {
    static var title: LocalizedStringResource = "Low Stock Medications"
    static var description = IntentDescription("List medications running low")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let medications = fetchLowStockMedications()
        
        if medications.isEmpty {
            return .result(dialog: "Your medication cabinet is well stocked!")
        } else {
            let names = medications.compactMap { $0.name }.joined(separator: ", ")
            let count = medications.count
            return .result(dialog: "You have \(count) medication\(count == 1 ? "" : "s") running low: \(names)")
        }
    }
    
    private func fetchLowStockMedications() -> [Medication] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "isLowStock == YES")
        request.fetchLimit = 5
        
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
}

// MARK: - App Shortcuts Provider
@available(iOS 16.0, *)
struct MedicinetimeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ExpiringSoonIntent(),
            phrases: [
                "Check expiring medications in \(.applicationName)",
                "What medications are expiring soon in \(.applicationName)"
            ],
            shortTitle: "Expiring Soon",
            systemImageName: "clock.fill"
        )
        
        AppShortcut(
            intent: LowStockIntent(),
            phrases: [
                "Check low stock in \(.applicationName)",
                "What medications are running low in \(.applicationName)"
            ],
            shortTitle: "Low Stock",
            systemImageName: "exclamationmark.triangle.fill"
        )
    }
}
