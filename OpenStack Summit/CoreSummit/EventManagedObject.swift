//
//  EventManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Predicate

public final class EventManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var socialDescription: String?
    
    @NSManaged public var start: Date
    
    @NSManaged public var end: Date
    
    @NSManaged public var allowFeedback: Bool
    
    @NSManaged public var averageFeedback: Double
    
    @NSManaged public var rsvp: String?
    
    @NSManaged public var externalRSVP: Bool
    
    @NSManaged public var willRecord: Bool
    
    @NSManaged public var attachment: String?
    
    @NSManaged public var track: TrackManagedObject?
    
    @NSManaged public var eventType: EventTypeManagedObject
    
    @NSManaged public var sponsors: Set<CompanyManagedObject>
    
    @NSManaged public var tags: Set<TagManagedObject>
    
    @NSManaged public var location: LocationManagedObject?
    
    @NSManaged public var presentation: PresentationManagedObject
    
    @NSManaged public var videos: Set<VideoManagedObject>
    
    @NSManaged public var slides: Set<SlideManagedObject>
    
    @NSManaged public var links: Set<LinkManagedObject>
    
    @NSManaged public var groups: Set<GroupManagedObject>
    
    @NSManaged public var summit: SummitManagedObject
    
    // MARK: - Inverse Relationhips
    
    @NSManaged public var attendees: Set<AttendeeManagedObject>
}

// MARK: - Encoding

extension Event: CoreDataDecodable {
    
    public init(managedObject: EventManagedObject) {
        
        self.identifier = managedObject.id
        self.summit = managedObject.summit.id
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.socialDescription = managedObject.socialDescription
        self.start = managedObject.start
        self.end = managedObject.end
        self.allowFeedback = managedObject.allowFeedback
        self.averageFeedback = managedObject.averageFeedback
        self.rsvp = managedObject.rsvp
        self.externalRSVP = managedObject.externalRSVP
        self.willRecord = managedObject.willRecord
        self.attachment = URL(string: managedObject.attachment ?? "")
        self.track = managedObject.track?.id
        self.type = managedObject.eventType.id
        self.sponsors = managedObject.sponsors.identifiers
        self.tags = Tag.from(managedObjects: managedObject.tags)
        self.location = managedObject.location?.id
        self.presentation = Presentation(managedObject: managedObject.presentation)
        self.videos = Video.from(managedObjects: managedObject.videos)
        self.slides = Slide.from(managedObjects: managedObject.slides)
        self.links = Link.from(managedObjects: managedObject.links)
        self.groups = Group.from(managedObjects: managedObject.groups)
    }
}

extension Event: CoreDataEncodable {
    
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
        managedObject.externalRSVP = externalRSVP
        managedObject.willRecord = willRecord
        managedObject.attachment = attachment?.absoluteString
        
        managedObject.summit = try context.relationshipFault(summit)
        managedObject.track = try context.relationshipFault(track)
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.sponsors = try context.relationshipFault(sponsors)
        managedObject.tags = try context.relationshipFault(tags)
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(videos)
        managedObject.slides = try context.relationshipFault(slides)
        managedObject.links = try context.relationshipFault(links)
        managedObject.groups = try context.relationshipFault(groups)
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberResponse.Event: CoreDataEncodable {
    
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
        managedObject.externalRSVP = externalRSVP
        managedObject.willRecord = willRecord
        managedObject.attachment = attachment?.absoluteString
        
        managedObject.summit = try context.relationshipFault(summit)
        managedObject.track = try context.relationshipFault(track)
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.sponsors = try context.relationshipFault(Set(sponsors))
        managedObject.tags = try context.relationshipFault(Set(tags))
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(Set(videos))
        managedObject.slides = try context.relationshipFault(Set(slides))
        managedObject.links = try context.relationshipFault(Set(links))
        managedObject.groups = try context.relationshipFault(Set(groups))
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension EventManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: #keyPath(EventManagedObject.start), ascending: true),
                NSSortDescriptor(key: #keyPath(EventManagedObject.end), ascending: true),
                NSSortDescriptor(key: #keyPath(EventManagedObject.name), ascending: true)]
    }
    
    static func search(_ searchTerm: String, context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        let value = Expression.value(.string(searchTerm))
        
        //let predicate = NSPredicate(format: "name CONTAINS [c] %@ or ANY presentation.speakers.firstName CONTAINS [c] %@ or ANY presentation.speakers.lastName CONTAINS [c] %@ or presentation.level CONTAINS [c] %@ or ANY tags.name CONTAINS [c] %@ or eventType.name CONTAINS [c] %@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm)
        let predicate: Predicate = (#keyPath(EventManagedObject.name)).compare(.contains, [.caseInsensitive], value)
            || (#keyPath(EventManagedObject.presentation.speakers.firstName)).compare(.any, .contains, [.caseInsensitive], value)
            || (#keyPath(EventManagedObject.presentation.speakers.lastName)).compare(.any, .contains, [.caseInsensitive], value)
            || (#keyPath(EventManagedObject.presentation.level)).compare(.contains, [.caseInsensitive], value)
            || (#keyPath(EventManagedObject.tags.name)).compare(.any, .contains, [.caseInsensitive], value)
            || (#keyPath(EventManagedObject.eventType.name)).compare(.contains, [.caseInsensitive], value)
        
        return try context.managedObjects(self, predicate: predicate, sortDescriptors: self.sortDescriptors)
    }
    
    static func filter(_ date: DateFilter,
                       tracks: [Identifier] = [],
                       trackGroups: [Identifier] = [],
                       levels: [Level] = [],
                       venues: [Identifier] = [],
                       summit: Identifier,
                       context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        let summitPredicate: Predicate = #keyPath(EventManagedObject.summit.id) == summit
        
        let datePredicate: Predicate
        
        switch date {
            
        case .now:
            
            let now = Date()
            
            //datePredicate = NSPredicate(format: "start <= %@ AND end >= %@", now, now)
            datePredicate = #keyPath(EventManagedObject.start) <= now
                && #keyPath(EventManagedObject.end) >= now
            
        case let .interval(start, end):
            
            //datePredicate = NSPredicate(format: "end >= %@ AND end <= %@", start, end)
            datePredicate = #keyPath(EventManagedObject.end) >= start
                && #keyPath(EventManagedObject.end) <= end
        }
        
        var predicates = [summitPredicate, datePredicate]
        
        if trackGroups.isEmpty == false {
            
            //let trackGroupPredicate = NSPredicate(format: "ANY track.groups.id IN %@", trackGroups)
            let trackGroupPredicate: Predicate = (#keyPath(EventManagedObject.track.groups.id)).any(in: trackGroups)
            
            predicates.append(trackGroupPredicate)
        }
        
        if tracks.isEmpty == false {
            
            //let tracksPredicate = NSPredicate(format: "track.id IN %@", tracks)
            let tracksPredicate: Predicate = (#keyPath(EventManagedObject.track.id)).in(tracks)
            
            predicates.append(tracksPredicate)
        }
        
        if levels.isEmpty == false {
            
            //let levelsPredicate = NSPredicate(format: "presentation.level IN %@", levels)
            let levelsPredicate: Predicate = (#keyPath(EventManagedObject.presentation.level)).in(levels.rawValues)
            
            predicates.append(levelsPredicate)
        }
        
        if venues.isEmpty == false {
            
            // NSPredicate(format: "venue.id IN %@", venues)
            let venueRoomsPredicate: Predicate = (#keyPath(VenueRoomManagedObject.venue.id)).in(venues)
            
            // get all rooms for the specified venue
            let venueRooms = try context.managedObjects(VenueRoomManagedObject.self, predicate: venueRoomsPredicate).identifiers
            
            let locations = venues + venueRooms
            
            //let predicate = NSPredicate(format: "location.id IN %@ OR location IN %@", venues, venueRooms)
            let predicate: Predicate = (#keyPath(EventManagedObject.location.id)).in(locations)
            
            predicates.append(predicate)
        }
        
        assert(predicates.count > 1)
        
        return try context.managedObjects(self,
                                          predicate: .compound(.and(predicates)),
                                          sortDescriptors: sortDescriptors)
    }
    
    static func presentations(for speaker: Identifier, start: Date, end: Date, summit: Identifier, context: NSManagedObjectContext) throws -> [EventManagedObject] {
        
        //let predicate = NSPredicate(format: "(ANY presentation.speakers == %@ OR presentation.moderator == %@) AND (end >= %@ AND end <= %@) AND summit == %@", speaker, speaker, startDate, endDate, summit)
        let predicate: Predicate = ((#keyPath(EventManagedObject.presentation.speakers.id)).any(in: [speaker])
            || #keyPath(EventManagedObject.presentation.moderator.id) == speaker)
            && #keyPath(EventManagedObject.end) >= start
            && #keyPath(EventManagedObject.end) <= end
            && #keyPath(EventManagedObject.summit.id) == summit
        
        return try context.managedObjects(self, predicate: predicate, sortDescriptors: sortDescriptors)
    }
}

// MARK: - Supporting Types

public extension EventManagedObject {
    
    public enum DateFilter {
        
        case now
        case interval(start: Date, end: Date)
    }
}
