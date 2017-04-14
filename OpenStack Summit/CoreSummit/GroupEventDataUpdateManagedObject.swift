//
//  GroupEventDataUpdateManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/26/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

extension GroupEventDataUpdate: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> EventManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.socialDescription = socialDescription
        managedObject.start = start
        managedObject.end = end
        managedObject.allowFeedback = allowFeedback
        managedObject.averageFeedback = averageFeedback
        managedObject.rsvp = rsvp
        managedObject.summit = try context.relationshipFault(summit)
        managedObject.track = try context.relationshipFault(track)
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.sponsors = try context.relationshipFault(Set(sponsors))
        managedObject.tags = try context.relationshipFault(Set(tags))
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(Set(videos))
        
        // Don't cache groups because they are incomplete data, we need more than just the identifier
        //managedObject.groups = try context.relationshipFault(Set(groups))
        
        managedObject.didCache()
        
        return managedObject
    }
}
