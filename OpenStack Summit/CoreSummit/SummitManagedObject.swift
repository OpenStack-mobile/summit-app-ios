//
//  SummitManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public final class SummitManagedObject: Entity {
    
    /// The date this summit was fetched from the server.
    @NSManaged public var initialDataLoad: NSDate?
    
    @NSManaged public var name: String
    
    @NSManaged public var timeZone: String
    
    @NSManaged public var datesLabel: String?
    
    @NSManaged public var start: NSDate
    
    @NSManaged public var end: NSDate
    
    @NSManaged public var defaultStart: NSDate?
    
    @NSManaged public var webpageURL: String
    
    @NSManaged public var active: Bool
    
    @NSManaged public var startShowingVenues: NSDate?
    
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
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.timeZone = managedObject.timeZone
        self.datesLabel = managedObject.datesLabel
        self.start = Date(foundation: managedObject.start)
        self.end = Date(foundation: managedObject.end)
        self.webpageURL = managedObject.webpageURL
        self.active = managedObject.active
        
        if let startShowingVenues = managedObject.startShowingVenues {
            
            self.startShowingVenues = Date(foundation: startShowingVenues)
            
        } else {
            
            self.startShowingVenues = nil
        }
        
        if let defaultStart = managedObject.defaultStart {
            
            self.defaultStart = Date(foundation: defaultStart)
            
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
    
    public func save(context: NSManagedObjectContext) throws -> SummitManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.timeZone = timeZone
        managedObject.datesLabel = datesLabel
        managedObject.start = start.toFoundation()
        managedObject.end = end.toFoundation()
        managedObject.defaultStart = defaultStart?.toFoundation()
        managedObject.webpageURL = webpageURL
        managedObject.active = active
        managedObject.startShowingVenues = startShowingVenues?.toFoundation()
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

