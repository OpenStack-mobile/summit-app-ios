//
//  SummitManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

public final class SummitManagedObject: Entity {
    
    /// The date this summit was fetched from the server.
    @NSManaged public var initialDataLoad: Date?
    
    @NSManaged public var name: String
    
    @NSManaged public var timeZone: String
    
    @NSManaged public var datesLabel: String?
    
    @NSManaged public var start: Date
    
    @NSManaged public var end: Date
    
    @NSManaged public var defaultStart: Date?
    
    @NSManaged public var webpageURL: String
    
    @NSManaged public var active: Bool
    
    @NSManaged public var startShowingVenues: Date?
    
    @NSManaged public var sponsors: Set<CompanyManagedObject>
    
    @NSManaged public var speakers: Set<SpeakerManagedObject>
        
    @NSManaged public var ticketTypes: Set<TicketTypeManagedObject>
    
    @NSManaged public var locations: Set<LocationManagedObject>
    
    @NSManaged public var tracks: Set<TrackManagedObject>
    
    @NSManaged public var trackGroups: Set<TrackGroupManagedObject>
    
    @NSManaged public var eventTypes: Set<EventTypeManagedObject>
    
    @NSManaged public var schedule: Set<EventManagedObject>
    
    @NSManaged public var wirelessNetworks: Set<WirelessNetworkManagedObject>
}

extension Summit: CoreDataDecodable {
    
    public init(managedObject: SummitManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.timeZone = managedObject.timeZone
        self.datesLabel = managedObject.datesLabel
        self.start = managedObject.start
        self.end = managedObject.end
        self.webpage = URL(string: managedObject.webpageURL)!
        self.active = managedObject.active
        
        if let startShowingVenues = managedObject.startShowingVenues {
            
            self.startShowingVenues = startShowingVenues
            
        } else {
            
            self.startShowingVenues = nil
        }
        
        if let defaultStart = managedObject.defaultStart {
            
            self.defaultStart = defaultStart
            
        } else {
            
            self.defaultStart = nil
        }
        
        self.sponsors = Company.from(managedObjects: managedObject.sponsors)
        self.speakers = Speaker.from(managedObjects: managedObject.speakers)
        self.ticketTypes = TicketType.from(managedObjects: managedObject.ticketTypes)
        self.locations = Location.from(managedObjects: managedObject.locations)
        self.tracks = Track.from(managedObjects: managedObject.tracks)
        self.trackGroups = TrackGroup.from(managedObjects: managedObject.trackGroups)
        self.eventTypes = EventType.from(managedObjects: managedObject.eventTypes)
        self.schedule = Event.from(managedObjects: managedObject.schedule)
        self.wirelessNetworks = WirelessNetwork.from(managedObjects: managedObject.wirelessNetworks)
    }
}

extension Summit: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> SummitManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.timeZone = timeZone
        managedObject.datesLabel = datesLabel
        managedObject.start = start
        managedObject.end = end
        managedObject.defaultStart = defaultStart
        managedObject.webpageURL = webpage.absoluteString
        managedObject.active = active
        managedObject.startShowingVenues = startShowingVenues
        managedObject.sponsors = try context.relationshipFault(sponsors)
        managedObject.speakers = try context.relationshipFault(speakers)
        managedObject.ticketTypes = try context.relationshipFault(ticketTypes)
        managedObject.locations = try context.relationshipFault(locations)
        managedObject.tracks = try context.relationshipFault(tracks)
        managedObject.trackGroups = try context.relationshipFault(trackGroups)
        managedObject.eventTypes = try context.relationshipFault(eventTypes)
        managedObject.schedule = try context.relationshipFault(schedule)
        managedObject.wirelessNetworks = try context.relationshipFault(wirelessNetworks)
        
        managedObject.didCache()
        
        return managedObject
    }
}

