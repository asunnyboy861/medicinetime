//
//  MedicationUsage+CoreDataClass.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData

@objc(MedicationUsage)
public class MedicationUsage: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var medicationID: UUID
    @NSManaged public var date: Date
    @NSManaged public var quantity: Int16
    @NSManaged public var usedBy: String
    @NSManaged public var actionType: String // "taken", "added", "removed", "expired"
    @NSManaged public var notes: String?
    @NSManaged public var medication: Medication?
}

// MARK: - Core Data Generated Code
@available(iOS 16.0, *)
extension MedicationUsage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicationUsage> {
        return NSFetchRequest<MedicationUsage>(entityName: "MedicationUsage")
    }
}
