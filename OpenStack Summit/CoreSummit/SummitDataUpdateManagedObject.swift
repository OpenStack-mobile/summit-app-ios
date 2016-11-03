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

extension SummitDataUpdate: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> SummitManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.timeZone = timeZone
        managedObject.start = start.toFoundation()
        managedObject.end = end.toFoundation()
        managedObject.webpageURL = webpageURL
        managedObject.startShowingVenues = startShowingVenues?.toFoundation()
        //managedObject.sponsors = try context.relationshipFault(sponsors)
        //managedObject.speakers = try context.relationshipFault(speakers)
        managedObject.summitTypes = try context.relationshipFault(summitTypes)
        managedObject.ticketTypes = try context.relationshipFault(ticketTypes)
        managedObject.locations = try context.relationshipFault(locations)
        //managedObject.tracks = try context.relationshipFault(tracks)
        //managedObject.trackGroups = try context.relationshipFault(trackGroups)
        //managedObject.eventTypes = try context.relationshipFault(eventTypes)
        //managedObject.schedule = try context.relationshipFault(schedule)
        
        //managedObject.didCache()
        
        return managedObject
    }
}