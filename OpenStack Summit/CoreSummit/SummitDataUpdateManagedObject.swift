//
//  SummitDataUpdateManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

extension SummitDataUpdate: Updatable {
    
    @inline(__always)
    static func find(identifier: Identifier, context: NSManagedObjectContext) throws -> Entity? {
        
        return try SummitManagedObject.find(identifier, context: context)
    }
    
    /// update current summit with Data Update
    func write(context: NSManagedObjectContext, summit: SummitManagedObject) throws -> Entity {
        
        let managedObject = summit
        
        managedObject.name = name
        managedObject.timeZone = timeZone
        managedObject.datesLabel = datesLabel
        managedObject.start = start.toFoundation()
        managedObject.end = end.toFoundation()
        managedObject.webpageURL = webpageURL
        managedObject.active = active
        managedObject.startShowingVenues = startShowingVenues?.toFoundation()
        managedObject.ticketTypes = try context.relationshipFault(ticketTypes)
        managedObject.locations = try context.relationshipFault(locations)
        
        if managedObject.cached != nil {
            
            managedObject.didCache()
        }
        
        return managedObject
    }
}