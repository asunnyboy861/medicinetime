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
        }
        
        // Data Migration Support (Automatic)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Store failed: \(error.localizedDescription)")
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
                fatalError("Failed to pin viewContext to current generation: \(error)")
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
            fatalError("Error saving preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
