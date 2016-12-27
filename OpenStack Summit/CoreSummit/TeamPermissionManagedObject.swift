//
//  TeamPermissionManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TeamPermissionManagedObject: NSManagedObject {
    
    @NSManaged public var type: String
    
    @NSManaged public var member: TeamMemberManagedObject
    
    // Inverse Relationships
    
    @NSManaged public var teamOwner: TeamManagedObject?
    
    @NSManaged public var teamMember: TeamManagedObject?
}

// MARK: - Encoding

extension TeamPermission: CoreDataDecodable {
    
    public init(managedObject: TeamPermissionManagedObject) {
        
        let team: TeamManagedObject
        
        let membership: TeamPermission.Membership
        
        if let teamOwner = managedObject.teamOwner {
            
            team = teamOwner
            
            membership = .owner
            
        } else if let teamMember = managedObject.teamMember {
            
            team = teamMember
            
            membership = .member
            
        } else {
            
            fatalError("Missing team: \(managedObject)")
        }
        
        self.team = team.identifier
        self.membership = membership
        self.type = PermissionType(rawValue: managedObject.type)!
        self.member = TeamMember(managedObject: managedObject.member)
    }
}

extension TeamPermission: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TeamPermissionManagedObject {
        
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel[ManagedObject.self]
            else { fatalError("Could not find entity") }
        
        let resourceID = self.identifier.rawValue as NSString
        
        let managedObject = try context.findOrCreate(entity,
                                                     resourceID: resourceID,
                                                     identifierProperty: "uuid",
                                                     returnsObjectsAsFaults: true,
                                                     includesSubentities: false) as ManagedObject
        
        
    }
}
