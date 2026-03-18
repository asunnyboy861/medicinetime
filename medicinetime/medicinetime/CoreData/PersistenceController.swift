//
//  PersistenceController.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import CoreData
import CloudKit
import Combine

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MedCabinet")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure CloudKit options
            if let description = container.persistentStoreDescriptions.first {
                // Enable automatic migration
                description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
                description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
                
                // Enable persistent history tracking
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                
                // Disable CloudKit remote notifications for simulator
                #if targetEnvironment(simulator)
                description.cloudKitContainerOptions = nil
                #else
                // Configure CloudKit for real devices
                let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.medcabinet")
                cloudKitOptions.databaseScope = .private
                description.cloudKitContainerOptions = cloudKitOptions
                #endif
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // More detailed error logging
                print("Core Data Store failed to load:")
                print("  Error Domain: \(error.domain)")
                print("  Error Code: \(error.code)")
                print("  Error Description: \(error.localizedDescription)")
                print("  Store Description: \(description)")
                
                // Don't crash - attempt recovery
                #if !targetEnvironment(simulator)
                // First attempt: try to delete corrupted store and recreate
                if let storeURL = description.url {
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        // Try to load again after deleting corrupted store
                        self.container.loadPersistentStores { _, retryError in
                            if let retryError = retryError as NSError? {
                                print("Failed to recreate store: \(retryError.localizedDescription)")
                                // Second attempt: disable CloudKit and use local-only store
                                description.cloudKitContainerOptions = nil
                                self.container.loadPersistentStores { _, fallbackError in
                                    if let fallbackError = fallbackError as NSError? {
                                        print("Fallback to local store also failed: \(fallbackError.localizedDescription)")
                                        // Last resort: use in-memory store
                                        self.container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
                                        self.container.loadPersistentStores { _, _ in }
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Failed to delete corrupted store: \(error.localizedDescription)")
                        // Fallback to in-memory store
                        self.container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
                        self.container.loadPersistentStores { _, _ in }
                    }
                }
                #endif
            } else {
                print("Core Data Store loaded successfully: \(description.url?.path ?? "unknown")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if !inMemory {
            container.viewContext.undoManager = nil
            container.viewContext.shouldDeleteInaccessibleFaults = true
            
            do {
                try container.viewContext.setQueryGenerationFrom(.current)
            } catch {
                print("Failed to pin viewContext to current generation: \(error)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Preview
extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample categories
        Category.defaultCategories.enumerated().forEach { index, category in
            let newCategory = Category(context: context)
            newCategory.id = UUID()
            newCategory.name = category.name
            newCategory.icon = category.icon
            newCategory.color = category.color
            newCategory.sortOrder = Int16(index)
        }
        
        // Create sample medications
        for i in 0..<5 {
            let medication = Medication(context: context)
            medication.id = UUID()
            medication.name = "Sample Med \(i + 1)"
            medication.category = Category.defaultCategories[i % Category.defaultCategories.count].name
            medication.expirationDate = Date().addingTimeInterval(TimeInterval(i * 30 * 86400))
            medication.purchaseDate = Date().addingTimeInterval(TimeInterval(-i * 30 * 86400))
            medication.quantity = Int16(20 - i * 3)
            medication.unit = "tablets"
            medication.lowStockThreshold = 5
            medication.lastUpdated = Date()
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
