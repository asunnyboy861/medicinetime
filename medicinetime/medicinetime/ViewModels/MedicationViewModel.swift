//
//  MedicationViewModel.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class MedicationViewModel: NSObject, ObservableObject {
    @Published var medications: [Medication] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var searchText = ""
    @Published var showingAddMedication = false
    @Published var errorMessage: String?
    @Published var expiryFilter: ExpiryFilter = .all
    @Published var stockFilter: StockFilter = .all
    
    private let persistenceController: PersistenceController
    private var fetchedResultsController: NSFetchedResultsController<Medication>?
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        super.init()
        setupFetchedResultsController()
        loadCategories()
    }
    
    // MARK: - Setup
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "expirationDate", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            medications = fetchedResultsController?.fetchedObjects ?? []
        } catch {
            print("Error fetching medications: \(error.localizedDescription)")
            errorMessage = "Unable to load medications. Please restart the app."
            medications = []
        }
    }
    
    private func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        
        do {
            categories = try persistenceController.container.viewContext.fetch(request)
            
            // If no categories exist, create default ones
            if categories.isEmpty {
                createDefaultCategories()
            }
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            errorMessage = "Unable to load categories. Please restart the app."
            categories = []
        }
    }
    
    private func createDefaultCategories() {
        let context = persistenceController.container.viewContext
        
        Category.defaultCategories.enumerated().forEach { index, category in
            let newCategory = Category(context: context)
            newCategory.id = UUID()
            newCategory.name = category.name
            newCategory.icon = category.icon
            newCategory.color = category.color
            newCategory.sortOrder = Int16(index)
        }
        
        persistenceController.saveContext()
        loadCategories()
    }
    
    // MARK: - CRUD Operations
    func addMedication(_ medication: Medication) {
        showingAddMedication = false
        persistenceController.saveContext()
        WidgetDataManager.shared.saveWidgetData(from: persistenceController.container.viewContext)
    }

    func updateMedication(_ medication: Medication) {
        medication.lastUpdated = Date()
        persistenceController.saveContext()
        WidgetDataManager.shared.saveWidgetData(from: persistenceController.container.viewContext)
    }

    func deleteMedication(_ medication: Medication) {
        persistenceController.container.viewContext.delete(medication)
        persistenceController.saveContext()
        WidgetDataManager.shared.saveWidgetData(from: persistenceController.container.viewContext)
    }
    
    func updateStock(medicationID: UUID, quantity: Int16) {
        if let medication = medications.first(where: { $0.id == medicationID }) {
            medication.quantity = quantity
            medication.isLowStock = quantity <= medication.lowStockThreshold
            medication.lastUsedDate = Date()
            updateMedication(medication)
        }
    }
    
    // MARK: - Filtering
    var filteredMedications: [Medication] {
        var result = medications
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category.name }
        }
        
        // Filter by expiry status
        switch expiryFilter {
        case .expired:
            result = result.filter { $0.isExpired }
        case .expiringSoon:
            result = result.filter { $0.expiryStatus == .expiringSoon || $0.expiryStatus == .expiringIn3Months }
        case .good:
            result = result.filter { $0.expiryStatus == .good }
        case .all:
            break
        }
        
        // Filter by stock status
        switch stockFilter {
        case .lowStock:
            result = result.filter { $0.needsRestock }
        case .inStock:
            result = result.filter { !$0.needsRestock }
        case .all:
            break
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    // MARK: - Statistics
    var totalMedications: Int {
        return medications.count
    }
    
    var expiringSoonCount: Int {
        return medications.filter { $0.expiryStatus == .expiringSoon || $0.expiryStatus == .expiringIn3Months }.count
    }
    
    var expiredCount: Int {
        return medications.filter { $0.isExpired }.count
    }
    
    var goodCount: Int {
        return medications.filter { $0.expiryStatus == .good }.count
    }
    
    var lowStockCount: Int {
        return medications.filter { $0.needsRestock }.count
    }
    
    func useMedication(_ medication: Medication, quantity: Int16, notes: String?) {
        Task {
            await NotificationManager.shared.recordMedicationUsage(
                medication: medication,
                quantity: quantity,
                notes: notes
            )
        }
    }

    // MARK: - Usage History

    func fetchUsageHistory(for medication: Medication) -> [MedicationUsage] {
        let request: NSFetchRequest<MedicationUsage> = MedicationUsage.fetchRequest()
        guard let medicationID = medication.id else { return [] }
        request.predicate = NSPredicate(format: "medicationID == %@", medicationID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching usage history: \(error)")
            return []
        }
    }
}

// MARK: - Filter Enums
enum ExpiryFilter: String, CaseIterable {
    case all = "All"
    case expired = "Expired"
    case expiringSoon = "Expiring Soon"
    case good = "Good"
}

enum StockFilter: String, CaseIterable {
    case all = "All"
    case lowStock = "Low Stock"
    case inStock = "In Stock"
}

// MARK: - NSFetchedResultsControllerDelegate
extension MedicationViewModel: NSFetchedResultsControllerDelegate {
    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task { @MainActor in
            medications = controller.fetchedObjects as? [Medication] ?? []
        }
    }
}
