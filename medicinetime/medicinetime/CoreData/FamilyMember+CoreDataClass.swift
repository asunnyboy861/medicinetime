//
//  FamilyMember+CoreDataClass.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation
import CoreData

@objc(FamilyMember)
public class FamilyMember: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var role: String // "admin" or "member"
    @NSManaged public var email: String?
    @NSManaged public var joinedDate: Date
    @NSManaged public var medications: NSSet?
}

// MARK: - Computed Properties
extension FamilyMember {
    public var isAdmin: Bool {
        return role == "admin"
    }
    
    public var canEdit: Bool {
        return isAdmin
    }
    
    public var canDelete: Bool {
        return isAdmin
    }
    
    public var canInvite: Bool {
        return isAdmin
    }
    
    public var canViewPrivate: Bool {
        return isAdmin
    }
}

// MARK: - Core Data Generated Code
@available(iOS 16.0, *)
extension FamilyMember {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FamilyMember> {
        return NSFetchRequest<FamilyMember>(entityName: "FamilyMember")
    }
}
