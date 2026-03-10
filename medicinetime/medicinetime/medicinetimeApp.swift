//
//  medicinetimeApp.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

@main
struct medicinetimeApp: App {
    @StateObject private var persistenceController = PersistenceController()
    @StateObject private var notificationManager = NotificationManager()
    @State private var shortcutAction: ShortcutAction?
    
    var body: some Scene {
        WindowGroup {
            ContentView(shortcutAction: $shortcutAction)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
                .environmentObject(notificationManager)
                .onAppear {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                    notificationManager.setupNotificationCategories()
                    setupShortcutItems()
                }
                .onChange(of: shortcutAction) { newValue in
                    // Handle shortcut action in ContentView
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add Medication") {
                    shortcutAction = .addMedication
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
