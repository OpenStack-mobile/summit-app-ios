//
//  TeamInvitationManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/2/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

public final class TeamInvitationManagedObject: Entity {
    
    @NSManaged public var created: Date
    
    @NSManaged public var updatedDate: Date
    
    @NSManaged public var permission: String
    
    @NSManaged public var accepted: Bool
    
    @NSManaged public var invitee: MemberManagedObject
    
    @NSManaged public var inviter: MemberManagedObject
    
    @NSManaged public var team: TeamManagedObject
}

// MARK: - Encoding

extension TeamInvitation: CoreDataDecodable {
    
    public init(managedObject: TeamInvitationManagedObject) {
        
        self.identifier = managedObject.id
        self.created = managedObject.created
        self.updated = managedObject.updatedDate
        self.accepted = managedObject.accepted
        self.permission = TeamPermission(rawValue: managedObject.permission)!
        self.invitee = Member(managedObject: managedObject.invitee)
        self.inviter = Member(managedObject: managedObject.inviter)
        self.team = managedObject.team.id
    }
}

extension TeamInvitation: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TeamInvitationManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.created = created
        managedObject.updatedDate = updated
        managedObject.accepted = accepted
        managedObject.permission = permission.rawValue
        managedObject.invitee = try context.relationshipFault(invitee)
        managedObject.inviter = try context.relationshipFault(inviter)
        managedObject.team = try context.relationshipFault(team)
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension ListTeamInvitations.Response.Invitation: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TeamInvitationManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.created = created
        managedObject.updatedDate = updated
        managedObject.accepted = accepted
        managedObject.permission = permission.rawValue
        managedObject.invitee = try context.relationshipFault(invitee)
        managedObject.inviter = try context.relationshipFault(inviter)
        managedObject.team = try context.relationshipFault(team)
        
        managedObject.didCache()
        
        return managedObject
    }
}
