//
//  NotificationManager.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    internal let center = UNUserNotificationCenter.current()
    private var medicationAdded = false
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    // MARK: - Permission Request
    func requestAuthorization() async -> Bool {
        // Best practice: Request after user adds first medication
        guard medicationAdded else {
            print("ℹ️ Notification request delayed until first medication is added")
            return false
        }
        
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            if granted {
                print("✅ Notification permission granted")
                scheduleDemoNotification()
            } else {
                print("❌ Notification permission denied")
            }
            
            return granted
        } catch {
            print("❌ Notification request error: \(error.localizedDescription)")
            return false
        }
    }
    
    func markMedicationAdded() {
        medicationAdded = true
        Task {
            await requestAuthorization()
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let userInfo = response.notification.request.content.userInfo as? [String: Any],
              let medicationIDString = userInfo["medicationID"] as? String,
              let medicationID = UUID(uuidString: medicationIDString) else {
            completionHandler()
            return
        }
        
        Task {
            await handleNotificationAction(
                identifier: response.actionIdentifier,
                for: medicationID
            )
            completionHandler()
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Scheduling
    func scheduleExpiryNotifications(for medication: Medication) {
        guard let medicationID = medication.id,
              let expirationDate = medication.expirationDate,
              let medicationName = medication.name else {
            return
        }
        
        // Remove existing notifications
        center.removePendingNotificationRequests(
            withIdentifiers: ["expiry_\(medicationID.uuidString)"]
        )
        
        // Schedule 3-month reminder
        scheduleNotification(
            id: "expiry_3m_\(medicationID.uuidString)",
            date: expirationDate.addingTimeInterval(-90 * 86400),
            title: "Medication Expiring Soon",
            body: "\(medicationName) will expire in 3 months. Time to check your supply!",
            categoryIdentifier: "EXPIRY_REMINDER"
        )
        
        // Schedule 1-month reminder
        scheduleNotification(
            id: "expiry_1m_\(medicationID.uuidString)",
            date: expirationDate.addingTimeInterval(-30 * 86400),
            title: "Time to Restock?",
            body: "\(medicationName) expires in 1 month. Consider purchasing a replacement.",
            categoryIdentifier: "EXPIRY_REMINDER"
        )
        
        // Schedule 1-week urgent reminder
        scheduleNotification(
            id: "expiry_1w_\(medicationID.uuidString)",
            date: expirationDate.addingTimeInterval(-7 * 86400),
            title: "⚠️ Urgent: Expiring Soon",
            body: "\(medicationName) expires in 1 week. Last chance to use it!",
            categoryIdentifier: "EXPIRY_URGENT"
        )
        
        // Schedule expiry day notification
        scheduleNotification(
            id: "expiry_day_\(medicationID.uuidString)",
            date: expirationDate,
            title: "❌ Expired Today",
            body: "\(medicationName) expires today. Please dispose of it safely.",
            categoryIdentifier: "EXPIRY_EXPIRED"
        )
    }
    
    private func scheduleNotification(
        id: String,
        date: Date,
        title: String,
        body: String,
        categoryIdentifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled: \(id)")
            }
        }
    }
    
    func cancelNotifications(for medicationID: UUID) {
        let identifiers = [
            "expiry_\(medicationID.uuidString)",
            "expiry_3m_\(medicationID.uuidString)",
            "expiry_1m_\(medicationID.uuidString)",
            "expiry_1w_\(medicationID.uuidString)",
            "expiry_day_\(medicationID.uuidString)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Demo
    private func scheduleDemoNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Welcome to MedCabinet!"
        content.body = "We'll help you track your medications and remind you before they expire."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "demo_notification",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
}
