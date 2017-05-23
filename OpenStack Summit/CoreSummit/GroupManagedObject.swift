//
//  GroupManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class GroupManagedObject: Entity {
    
    @NSManaged public var title: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var code: String
}

// MARK: - Encoding

extension Group: CoreDataDecodable {
    
    public init(managedObject: GroupManagedObject) {
        
        self.identifier = managedObject.id
        self.title = managedObject.title
        self.descriptionText = managedObject.descriptionText
        self.code = managedObject.code
    }
}

extension Group: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> GroupManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.title = title
        managedObject.descriptionText = descriptionText
        managedObject.code = code
        
        managedObject.didCache()
        
        return managedObject
    }
}
