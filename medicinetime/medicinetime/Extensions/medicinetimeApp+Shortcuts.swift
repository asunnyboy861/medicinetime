//
//  medicinetimeApp+Shortcuts.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import UIKit
import SwiftUI

extension medicinetimeApp {
    func setupShortcutItems() {
        let addMedication = UIApplicationShortcutItem(
            type: "com.medcabinet.addMedication",
            localizedTitle: "Add Medication",
            localizedSubtitle: "Add to your cabinet",
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"),
            userInfo: nil
        )
        
        let searchMedication = UIApplicationShortcutItem(
            type: "com.medcabinet.search",
            localizedTitle: "Search",
            localizedSubtitle: "Find medications",
            icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass"),
            userInfo: nil
        )
        
        let expiringSoon = UIApplicationShortcutItem(
            type: "com.medcabinet.expiringSoon",
            localizedTitle: "Expiring Soon",
            localizedSubtitle: "View expiring meds",
            icon: UIApplicationShortcutIcon(systemImageName: "clock.fill"),
            userInfo: nil
        )
        
        let lowStock = UIApplicationShortcutItem(
            type: "com.medcabinet.lowStock",
            localizedTitle: "Low Stock",
            localizedSubtitle: "View low stock meds",
            icon: UIApplicationShortcutIcon(systemImageName: "exclamationmark.triangle.fill"),
            userInfo: nil
        )
        
        UIApplication.shared.shortcutItems = [
            addMedication, searchMedication, expiringSoon, lowStock
        ]
    }
    
    func handleShortcutItem(_ item: UIApplicationShortcutItem) -> ShortcutAction? {
        switch item.type {
        case "com.medcabinet.addMedication":
            return .addMedication
        case "com.medcabinet.search":
            return .search
        case "com.medcabinet.expiringSoon":
            return .expiringSoon
        case "com.medcabinet.lowStock":
            return .lowStock
        default:
            return nil
        }
    }
}

enum ShortcutAction: String, Identifiable {
    case addMedication
    case search
    case expiringSoon
    case lowStock
    
    var id: String { rawValue }
}
