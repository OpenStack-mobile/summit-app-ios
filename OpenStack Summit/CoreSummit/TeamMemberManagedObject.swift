//
//  TeamMemberManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TeamMemberManagedObject: Entity {
    
    @NSManaged public var permission: String
    
    @NSManaged public var team: TeamManagedObject
    
    @NSManaged public var member: MemberManagedObject
}

// MARK: - Encoding

extension TeamMember: CoreDataDecodable {
    
    public init(managedObject: TeamMemberManagedObject) {
        
        self.identifier = managedObject.id
        self.permission = TeamPermission(rawValue: managedObject.permission)!
        self.team = managedObject.team.id
        self.member = Member(managedObject: managedObject.member)
    }
}

extension TeamMember: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TeamMemberManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.permission = permission.rawValue
        managedObject.team = try context.relationshipFault(team)
        managedObject.member = try context.relationshipFault(member)
        
        managedObject.didCache()
        
        return managedObject
    }
}
