//
//  PresentationDataUpdateManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

extension PresentationDataUpdate: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> PresentationManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.level = level?.rawValue
        managedObject.speakers = try context.relationshipFault(speakers)
        
        managedObject.didCache()
        
        return managedObject
    }
}
