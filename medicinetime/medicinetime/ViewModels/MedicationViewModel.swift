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
            errorMessage = "Error fetching medications: \(error.localizedDescription)"
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
            errorMessage = "Error fetching categories: \(error.localizedDescription)"
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
    }
    
    func updateMedication(_ medication: Medication) {
        medication.lastUpdated = Date()
        persistenceController.saveContext()
    }
    
    func deleteMedication(_ medication: Medication) {
        persistenceController.container.viewContext.delete(medication)
        persistenceController.saveContext()
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
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension MedicationViewModel: NSFetchedResultsControllerDelegate {
    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task { @MainActor in
            medications = controller.fetchedObjects as? [Medication] ?? []
        }
    }
}
