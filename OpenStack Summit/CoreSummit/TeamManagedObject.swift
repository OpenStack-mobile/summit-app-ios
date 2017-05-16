//
//  TeamManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TeamManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var created: Date
    
    @NSManaged public var updatedDate: Date
    
    @NSManaged public var owner: MemberManagedObject
    
    @NSManaged public var members: Set<TeamMemberManagedObject>
    
    @NSManaged public var invitations: Set<TeamInvitationManagedObject>
    
    // Inverse Relationships
    
    @NSManaged public var messages: Set<TeamMessageManagedObject>
}

// MARK: - Encoding

extension Team: CoreDataDecodable {
    
    public init(managedObject: TeamManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.created = managedObject.created
        self.updated = managedObject.updatedDate
        self.descriptionText = managedObject.descriptionText
        self.owner = Member(managedObject: managedObject.owner)
        self.members = TeamMember.from(managedObjects: managedObject.members)
        self.invitations = TeamInvitation.from(managedObjects: managedObject.invitations)
    }
}

extension Team: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TeamManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.created = created
        managedObject.updatedDate = updated
        
        // delete previous team members and owner, to not have nil inverse relationships
        managedObject.members.forEach { context.delete($0) }
        
        // set members
        managedObject.owner = try context.relationshipFault(owner)
        managedObject.members = try context.relationshipFault(members)
        
        // set invitations
        managedObject.invitations.forEach { context.delete($0) } // invitations must always have a team
        managedObject.invitations = try context.relationshipFault(invitations)
        
        managedObject.didCache()
        
        return managedObject
    }
}
