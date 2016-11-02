//
//  EventManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public final class EventManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var start: NSDate
    
    @NSManaged public var end: NSDate
    
    @NSManaged public var allowFeedback: Bool
    
    @NSManaged public var averageFeedback: Double
    
    @NSManaged public var rsvp: String?
    
    @NSManaged public var eventType: EventTypeManagedObject
    
    @NSManaged public var summitTypes: Set<SummitTypeManagedObject>
    
    @NSManaged public var sponsors: Set<CompanyManagedObject>
    
    @NSManaged public var tags: Set<TagManagedObject>
    
    @NSManaged public var location: LocationManagedObject?
    
    @NSManaged public var presentation: PresentationManagedObject?
    
    @NSManaged public var videos: Set<VideoManagedObject>
}

extension Event: CoreDataDecodable {
    
    public init(managedObject: EventManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.start = Date(foundation: managedObject.start)
        self.end = Date(foundation: managedObject.end)
        self.allowFeedback = managedObject.allowFeedback
        self.averageFeedback = managedObject.averageFeedback
        self.rsvp = managedObject.rsvp
        self.type = managedObject.eventType.identifier
        self.summitTypes = managedObject.summitTypes.identifiers
        self.sponsors = managedObject.sponsors.identifiers
        self.tags = Tag.from(managedObjects: managedObject.tags)
        self.location = managedObject.location?.identifier
        
        if let presentationManagedObject = managedObject.presentation {
            
            self.presentation = Presentation(managedObject: presentationManagedObject)
            
        } else {
            
            self.presentation = nil
        }
        
        self.videos = Video.from(managedObjects: managedObject.videos)
    }
}

extension Event: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> EventManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.start = start.toFoundation()
        managedObject.end = end.toFoundation()
        managedObject.allowFeedback = allowFeedback
        managedObject.averageFeedback = averageFeedback
        managedObject.rsvp = rsvp
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.summitTypes = try context.relationshipFault(summitTypes, SummitType.self)
        managedObject.sponsors = try context.relationshipFault(sponsors, Company.self)
        managedObject.tags = try context.relationshipFault(tags)
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(videos)
        
        managedObject.didCache()
        
        return managedObject
    }
}