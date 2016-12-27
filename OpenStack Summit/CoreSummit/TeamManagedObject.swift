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
    
    @NSManaged public var descriptionText: String
    
    @NSManaged public var owner: TeamMemberManagedObject
    
    @NSManaged public var members: Set<TeamMemberManagedObject>
    
    // Inverse Relationships
    
    @NSManaged public var messages: Set<TeamMessageManagedObject>
}

// MARK: - Encoding

extension Team: CoreDataDecodable {
    
    public init(managedObject: TeamManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.owner = TeamMember(managedObject: managedObject.owner)
        self.members = TeamMember.from(managedObjects: managedObject.members)
    }
}

extension Team: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TeamManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.owner = try context.relationshipFault(owner)
        managedObject.members = try context.relationshipFault(members)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension TeamManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}
