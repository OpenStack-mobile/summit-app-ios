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
    
    // Inverse Relationships
    
    @NSManaged public var summit: SummitManagedObject
}

// MARK: - Encoding

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
        managedObject.summitTypes = try context.relationshipFault(summitTypes)
        managedObject.sponsors = try context.relationshipFault(sponsors)
        managedObject.tags = try context.relationshipFault(tags)
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(videos)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension EventManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "start", ascending: true),
                NSSortDescriptor(key: "end", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)]
    }
    
    static func filter(startDate: NSDate,
                       endDate: NSDate,
                       summitTypes: [Identifier]?,
                       tracks: [Identifier]?,
                       trackGroups: [Identifier]?,
                       tags: [String]?,
                       levels: [String]?,
                       venues: [Identifier]?,
                       context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        let eventsPredicate = NSPredicate(format: "start >= %@ AND end <= %@", startDate, endDate)
        
        var predicates = [eventsPredicate]
        
        if let summitTypes = summitTypes where summitTypes.isEmpty == false {
            
            let summitTypePredicate = NSPredicate(format: "ANY summitTypes.id IN %@", summitTypes)
            
            predicates.append(summitTypePredicate)
        }
        
        if let trackGroups = trackGroups where trackGroups.isEmpty == false {
            
            let trackGroupPredicate = NSPredicate(format: "ANY presentation.track.groups.id IN %@", trackGroups)
            
            predicates.append(trackGroupPredicate)
        }
        
        if let tracks = tracks where tracks.isEmpty == false {
            
            let tracksPredicate = NSPredicate(format: "presentation.track.id IN %@", tracks)
            
            predicates.append(tracksPredicate)
        }
        
        if let levels = levels where levels.isEmpty == false {
            
            let levelsPredicate = NSPredicate(format: "presentation.level IN %@", levels)
            
            predicates.append(levelsPredicate)
        }
        
        if let tags = tags where tags.isEmpty == false {
            
            let tagPredicates = tags.map { NSPredicate(format: "ANY tags.name ==[c] %@", $0) }
            
            let predicate: NSPredicate
            
            if tagPredicates.count > 1 {
                
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: tagPredicates)
                
            } else {
                
                predicate = predicates[0]
            }
            
            predicates.append(predicate)
        }
        
        if let venues = venues where venues.isEmpty == false {
            
            let predicate = NSPredicate(format: "location.id IN %@", venues)
            
            predicates.append(predicate)
        }
        
        let predicate: NSPredicate
            
        if predicates.count > 1 {
            
           predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
        } else {
            
            predicate = predicates[0]
        }
        
        return try context.managedObjects(EventManagedObject.self, predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    static func speakerPresentations(speaker: Identifier, startDate: NSDate, endDate: NSDate, context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        let predicate = NSPredicate(format: "ANY presentation.speakers.id == %@ || presentation.moderator.id == %@ && start >= %@ AND end <= %@", speaker, speaker, startDate, endDate)
        
        return try context.managedObjects(EventManagedObject.self, predicate: predicate, sortDescriptors: sortDescriptors)
    }
}

public extension Event {
    
    static func search(searchTerm: String, context: NSManagedObjectContext) throws -> [Event] {
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
        return try context.managedObjects(self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors)
    }
}
