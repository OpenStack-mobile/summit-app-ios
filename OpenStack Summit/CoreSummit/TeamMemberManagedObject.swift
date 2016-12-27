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
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var permission: String
    
    // Inverse relationship
    
    @NSManaged public var teamMember: Set<TeamPermissionManagedObject>
    
    @NSManaged public var teamOwner: Set<TeamPermissionManagedObject>
}

// MARK: - Encoding

extension TeamMember: CoreDataDecodable {
    
    public init(managedObject: TeamMemberManagedObject) {
        
        self.firstName = managedObject.firstName
        self.lastName = managedObject.lastName
        self.pictureURL = managedObject.pictureURL
        self.twitter = managedObject.twitter
        self.irc = managedObject.irc
        self.permission = Permission(rawValue: managedObject.permission)!
    }
}

extension TeamMember: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TeamMemberManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.pictureURL = pictureURL
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.permission = permission.rawValue
        
        managedObject.didCache()
        
        return managedObject
    }
}
