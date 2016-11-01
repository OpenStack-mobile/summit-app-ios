//
//  EventManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

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
    
    @NSManaged public var location: LocationManagedObject
    
    @NSManaged public var presentation: PresentationManagedObject?
    
    @NSManaged public var videos: Set<VideoManagedObject>
}