//
//  medicinetimeApp.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

@main
struct medicinetimeApp: App {
    @StateObject private var viewModel: MedicationViewModel
    @StateObject private var notificationManager = NotificationManager()
    @State private var shortcutAction: ShortcutAction?
    
    init() {
        let persistence = PersistenceController.shared
        _viewModel = StateObject(wrappedValue: MedicationViewModel(persistenceController: persistence))
        _notificationManager = StateObject(wrappedValue: NotificationManager())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, shortcutAction: $shortcutAction)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(PersistenceController.shared)
                .environmentObject(notificationManager)
                .onAppear {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                    notificationManager.setupNotificationCategories()
                    setupShortcutItems()
                }
                .onChange(of: shortcutAction) { oldValue, newValue in
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
