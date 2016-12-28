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
        self.member = Member(managedObject: managedObject.member)
    }
}

extension TeamMember: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TeamMemberManagedObject {
        
        let managedObject: ManagedObject
        
        if let foundManagedObject = try ManagedObject.find(team: team, member: member.identifier, context: context) {
            
            managedObject = foundManagedObject
            
        } else {
            
            managedObject = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(TeamMemberManagedObject.self), inManagedObjectContext: context) as! ManagedObject
        }
        
        managedObject.member = try context.relationshipFault(member)
        
        managedObject.permission = permission.rawValue
        
        switch membership {
            
        case .member:
            
            managedObject.teamMember = try context.relationshipFault(team)
            managedObject.teamOwner = nil
            
        case .owner:
            
            managedObject.teamOwner = try context.relationshipFault(team)
            managedObject.teamMember = nil
        }
        
        return managedObject
    }
}

// MARK: - Fetches

public extension TeamMemberManagedObject {
    
    static func find(team team: Identifier, member: Identifier, context: NSManagedObjectContext) throws -> TeamMemberManagedObject? {
        
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel[self]
            else { fatalError("Could not find entity") }
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.includesSubentities = false
        fetchRequest.returnsObjectsAsFaults = false
        
        // create predicate
        
        fetchRequest.predicate = NSPredicate(format: "(teamOwner.id == %@ || teamMember.id == %@) && member.id == %@", Int64(team), Int64(team), Int64(member))
        
        // fetch
        return try context.executeFetchRequest(fetchRequest).first as! TeamMemberManagedObject?
    }
}
