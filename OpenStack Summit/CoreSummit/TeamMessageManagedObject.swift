//
//  TeamMessageManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

public final class TeamMessageManagedObject: Entity {
        
    @NSManaged public var body: String
    
    @NSManaged public var created: Date
    
    @NSManaged public var team: TeamManagedObject
    
    @NSManaged public var from: MemberManagedObject
}

// MARK: - Encoding

extension TeamMessage: CoreDataDecodable {
    
    public init(managedObject: TeamMessageManagedObject) {
        
        self.identifier = managedObject.id
        self.body = managedObject.body
        self.created = managedObject.created
        self.from = Fault<Member>(managedObject: managedObject.from)
        self.team = Fault<Team>(managedObject: managedObject.team)
    }
}

extension TeamMessage: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TeamMessageManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.body = body
        managedObject.created = created
        managedObject.from = try context.relationshipFault(from)
        managedObject.team = try context.relationshipFault(team)
        
        managedObject.didCache()
        
        return managedObject
    }
}
