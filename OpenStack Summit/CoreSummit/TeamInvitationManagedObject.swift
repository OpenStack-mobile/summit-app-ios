//
//  TeamInvitationManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/2/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public final class TeamInvitationManagedObject: Entity {
    
    @NSManaged public var created: NSDate
    
    @NSManaged public var permission: String
    
    @NSManaged public var invitee: MemberManagedObject
    
    @NSManaged public var inviter: MemberManagedObject
    
    @NSManaged public var team: TeamManagedObject
}

// MARK: - Encoding

extension TeamInvitation: CoreDataDecodable {
    
    public init(managedObject: TeamInvitationManagedObject) {
        
        self.identifier = managedObject.identifier
        self.created = Date(foundation: managedObject.created)
        self.permission = TeamPermission(rawValue: managedObject.permission)!
        self.invitee = Member(managedObject: managedObject.invitee)
        self.inviter = Member(managedObject: managedObject.inviter)
        self.team = Team(managedObject: managedObject.team)
    }
}

extension TeamInvitation: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TeamInvitationManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.created = created.toFoundation()
        managedObject.permission = permission.rawValue
        managedObject.invitee = try context.relationshipFault(invitee)
        managedObject.inviter = try context.relationshipFault(inviter)
        managedObject.team = try context.relationshipFault(team)
        
        managedObject.didCache()
        
        return managedObject
    }
}
