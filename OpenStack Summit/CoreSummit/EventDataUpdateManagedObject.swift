//
//  EventDataUpdateManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

extension Event.DataUpdate: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> EventManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.start = start.toFoundation()
        managedObject.end = end.toFoundation()
        managedObject.allowFeedback = allowFeedback
        managedObject.averageFeedback = averageFeedback
        //managedObject.rsvp = rsvp
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.summitTypes = try context.relationshipFault(summitTypes)
        managedObject.sponsors = try context.relationshipFault(sponsors)
        managedObject.tags = try context.relationshipFault(tags)
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(videos)
        
        //managedObject.didCache()
        
        return managedObject
    }
}