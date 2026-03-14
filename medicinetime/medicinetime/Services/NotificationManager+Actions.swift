//
//  NotificationManager+Actions.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import UserNotifications
import CoreData

extension NotificationManager {
    func setupNotificationCategories() {
        // Define actions
        let useAction = UNNotificationAction(
            identifier: "USE_MEDICATION",
            title: "Mark as Used",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Me Later",
            options: []
        )
        
        let markExpiredAction = UNNotificationAction(
            identifier: "MARK_EXPIRED",
            title: "Mark as Expired",
            options: [.destructive]
        )
        
        // Define categories
        let expiryCategory = UNNotificationCategory(
            identifier: "EXPIRY_REMINDER",
            actions: [useAction, remindLaterAction, markExpiredAction],
            intentIdentifiers: [],
            options: []
        )
        
        let urgentCategory = UNNotificationCategory(
            identifier: "EXPIRY_URGENT",
            actions: [useAction, remindLaterAction, markExpiredAction],
            intentIdentifiers: [],
            options: []
        )
        
        let expiredCategory = UNNotificationCategory(
            identifier: "EXPIRY_EXPIRED",
            actions: [markExpiredAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories([
            expiryCategory, urgentCategory, expiredCategory
        ])
    }
    
    func handleNotificationAction(identifier: String, for medicationID: UUID) async {
        switch identifier {
        case "USE_MEDICATION":
            await handleUseMedication(medicationID: medicationID)
        case "REMIND_LATER":
            await handleRemindLater(medicationID: medicationID)
        case "MARK_EXPIRED":
            await handleMarkExpired(medicationID: medicationID)
        default:
            break
        }
    }
    
    private func handleUseMedication(medicationID: UUID) async {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicationID as CVarArg)
        
        do {
            let medications = try context.fetch(request)
            guard let medication = medications.first else { return }
            
            await recordMedicationUsage(medication: medication, quantity: 1, notes: nil)
        } catch {
            print("Error fetching medication: \(error)")
        }
    }
    
    public func recordMedicationUsage(
        medication: Medication,
        quantity: Int16,
        notes: String?
    ) async {
        let context = PersistenceController.shared.container.viewContext
        
        await MainActor.run {
            medication.quantity = max(0, medication.quantity - quantity)
            medication.lastUsedDate = Date()
            medication.lastUpdated = Date()
            
            if medication.quantity <= medication.lowStockThreshold {
                medication.isLowStock = true
            }
            
            let usage = MedicationUsage(context: context)
            usage.id = UUID()
            usage.medicationID = medication.id
            usage.date = Date()
            usage.quantity = quantity
            usage.notes = notes
            usage.actionType = "use"
            usage.medication = medication
            
            do {
                try context.save()
                
                if medication.needsRestock {
                    scheduleLowStockNotification(for: medication)
                }
            } catch {
                print("Error recording medication usage: \(error)")
            }
        }
    }
    
    private func handleRemindLater(medicationID: UUID) async {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicationID as CVarArg)
        
        do {
            let medications = try context.fetch(request)
            guard let medication = medications.first else { return }
            
            let medicationName = medication.name ?? "Medication"
            
            // Schedule new notification for 1 hour later
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "\(medicationName) is expiring soon. Don't forget to check it!"
            content.sound = .default
            content.categoryIdentifier = "EXPIRY_REMINDER"
            content.userInfo = ["medicationID": medicationID.uuidString]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            let request = UNNotificationRequest(
                identifier: "reminder_later_\(medicationID.uuidString)",
                content: content,
                trigger: trigger
            )
            
            try? await center.add(request)
        } catch {
            print("Error scheduling remind later: \(error)")
        }
    }
    
    private func handleMarkExpired(medicationID: UUID) async {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicationID as CVarArg)
        
        do {
            let medications = try context.fetch(request)
            guard let medication = medications.first else { return }
            
            await MainActor.run {
                // Set expiration date to past
                medication.expirationDate = Date().addingTimeInterval(-86400)
                medication.lastUpdated = Date()
                
                do {
                    try context.save()
                } catch {
                    print("Error marking medication as expired: \(error)")
                }
            }
        } catch {
            print("Error fetching medication: \(error)")
        }
    }
    
    private func scheduleLowStockNotification(for medication: Medication) {
        guard let medicationID = medication.id else { return }
        let medicationName = medication.name ?? "Medication"
        let medicationUnit = medication.unit ?? "units"
        
        // Remove existing low stock notifications
        center.removePendingNotificationRequests(
            withIdentifiers: ["low_stock_\(medicationID.uuidString)"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Low Stock Alert"
        content.body = "\(medicationName) is running low. Only \(medication.quantity) \(medicationUnit) left."
        content.sound = .default
        content.categoryIdentifier = "LOW_STOCK"
        content.userInfo = ["medicationID": medicationID.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "low_stock_\(medicationID.uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
}
