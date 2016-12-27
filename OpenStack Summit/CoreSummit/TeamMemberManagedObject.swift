//
//  TeamMemberManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TeamMemberManagedObject: NSManagedObject {
    
    @NSManaged public var permission: String
    
    @NSManaged public var member: MemberManagedObject
    
    // Inverse Relationships
    
    @NSManaged public var teamOwner: TeamManagedObject?
    
    @NSManaged public var teamMember: TeamManagedObject?
}

// MARK: - Encoding

extension TeamMember: CoreDataDecodable {
    
    public init(managedObject: TeamMemberManagedObject) {
        
        let team: TeamManagedObject
        
        let membership: TeamMembership
        
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
        self.permission = TeamPermission(rawValue: managedObject.permission)!
        self.member = TeamMember(managedObject: managedObject.member)
    }
}

extension TeamMember: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TeamMemberManagedObject {
        
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

// MARK: - Fetches

public extension TeamMemberManagedObject {
    
    static func find()
}
