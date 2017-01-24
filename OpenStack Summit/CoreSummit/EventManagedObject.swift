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
    
    @NSManaged public var socialDescription: String?
    
    @NSManaged public var start: NSDate
    
    @NSManaged public var end: NSDate
    
    @NSManaged public var allowFeedback: Bool
    
    @NSManaged public var averageFeedback: Double
    
    @NSManaged public var rsvp: String?
    
    @NSManaged public var track: TrackManagedObject?
    
    @NSManaged public var eventType: EventTypeManagedObject
    
    @NSManaged public var sponsors: Set<CompanyManagedObject>
    
    @NSManaged public var tags: Set<TagManagedObject>
    
    @NSManaged public var location: LocationManagedObject?
    
    @NSManaged public var presentation: PresentationManagedObject
    
    @NSManaged public var videos: Set<VideoManagedObject>
    
    @NSManaged public var groups: Set<GroupManagedObject>
    
    @NSManaged public var summit: SummitManagedObject
}

// MARK: - Encoding

extension Event: CoreDataDecodable {
    
    public init(managedObject: EventManagedObject) {
        
        self.identifier = managedObject.identifier
        self.summit = managedObject.summit.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.socialDescription = managedObject.socialDescription
        self.start = Date(foundation: managedObject.start)
        self.end = Date(foundation: managedObject.end)
        self.allowFeedback = managedObject.allowFeedback
        self.averageFeedback = managedObject.averageFeedback
        self.rsvp = managedObject.rsvp
        self.track = managedObject.track?.identifier
        self.type = managedObject.eventType.identifier
        self.sponsors = managedObject.sponsors.identifiers
        self.tags = Tag.from(managedObjects: managedObject.tags)
        self.location = managedObject.location?.identifier
        self.presentation = Presentation(managedObject: managedObject.presentation)
        self.videos = Video.from(managedObjects: managedObject.videos)
        self.groups = Group.from(managedObjects: managedObject.groups)
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
        managedObject.summit = try context.relationshipFault(summit)
        managedObject.track = try context.relationshipFault(track)
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.sponsors = try context.relationshipFault(sponsors)
        managedObject.tags = try context.relationshipFault(tags)
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(videos)
        managedObject.groups = try context.relationshipFault(groups)
        
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
    
    static func search(searchTerm: String, context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        let predicate = NSPredicate(format: "name CONTAINS [c] %@ or ANY presentation.speakers.firstName CONTAINS [c] %@ or ANY presentation.speakers.lastName CONTAINS [c] %@ or presentation.level CONTAINS [c] %@ or ANY tags.name CONTAINS [c] %@ or eventType.name CONTAINS [c] %@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm)
        
        return try context.managedObjects(self, predicate: predicate, sortDescriptors: self.sortDescriptors)
    }
    
    static func filter(startDate: NSDate,
                       endDate: NSDate,
                       tracks: [Identifier]?,
                       trackGroups: [Identifier]?,
                       tags: [String]?,
                       levels: [String]?,
                       venues: [Identifier]?,
                       summit: Identifier,
                       context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        guard let summit = try SummitManagedObject.find(summit, context: context)
            else { return [] }
        
        let eventsPredicate = NSPredicate(format: "end >= %@ AND end <= %@ AND summit == %@", startDate, endDate, summit)
        
        var predicates = [eventsPredicate]
        
        if let trackGroups = trackGroups where trackGroups.isEmpty == false {
            
            let trackGroupPredicate = NSPredicate(format: "ANY track.groups.id IN %@", trackGroups)
            
            predicates.append(trackGroupPredicate)
        }
        
        if let tracks = tracks where tracks.isEmpty == false {
            
            let tracksPredicate = NSPredicate(format: "track.id IN %@", tracks)
            
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
            
            // get all rooms for the specified venue
            let venueRooms = try context.managedObjects(VenueRoomManagedObject.self, predicate: NSPredicate(format: "venue.id IN %@", venues))
            
            let predicate = NSPredicate(format: "location.id IN %@ OR location IN %@", venues, venueRooms)
            
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
    
    static func speakerPresentations(speaker: Identifier, startDate: NSDate, endDate: NSDate, summit: Identifier, context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        guard let speaker = try SpeakerManagedObject.find(speaker, context: context),
            let summit = try SummitManagedObject.find(summit, context: context)
            else { return [] }
        
        let predicate = NSPredicate(format: "(ANY presentation.speakers == %@ OR presentation.moderator == %@) AND (end >= %@ AND end <= %@) AND summit == %@", speaker, speaker, startDate, endDate, summit)
        
        return try context.managedObjects(EventManagedObject.self, predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
