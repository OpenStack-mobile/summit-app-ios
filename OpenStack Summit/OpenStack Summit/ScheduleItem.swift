//
//  ScheduleItem.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit
import CoreData
import struct Foundation.Date

public struct ScheduleItem: CoreDataDecodable {
    
    // MARK: - Properties
    
    public let identifier: Identifier
    public let name: String
    public let summit: Identifier
    public let start: Date
    public let end: Date
    public let dateTime: String
    public let time: String
    public let location: String
    public let track: String
    public let sponsors: String
    public let eventType: String
    public let trackGroupColor: String
    
    // MARK: - Initialization
    
    public init(managedObject event: EventManagedObject) {
        
        self.identifier = event.id
        self.name = event.name
        self.summit = event.summit.id
        self.start = event.start
        self.end = event.end
        self.eventType = event.eventType.name
        self.location = ScheduleItem.getLocation(event)
        self.dateTime = ScheduleItem.getDateTime(event)
        self.time = ScheduleItem.getTime(event)
        self.track = ScheduleItem.getTrack(event)
        self.sponsors = ScheduleItem.getSponsors(event)
        self.trackGroupColor = ScheduleItem.getTrackGroupColor(event)
    }
}

// MARK: - Fetches

public extension ScheduleItem {
    
    static func search(_ searchTerm: String, context: NSManagedObjectContext) throws -> [ScheduleItem] {
        
        let managedObjects = try EventManagedObject.search(searchTerm, context: context)
        
        return ScheduleItem.from(managedObjects: managedObjects)
    }
}

// MARK: - Internal Extension

internal extension ScheduleItem {
    
    static func getSponsors(_ event: EventManagedObject) -> String {
        
        guard event.sponsors.isEmpty == false
            else { return "" }
        
        var sponsors = "Sponsored by "
        var separator = ""
        for sponsor in event.sponsors {
            sponsors += separator + sponsor.name
            separator = ", "
            assert(sponsor.name.isEmpty == false, "Empty sponsor name")
        }
        return sponsors
    }
    
    static func getTime(_ event: EventManagedObject) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: event.summit.timeZone)
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        let stringDateFrom = dateFormatter.string(from: event.start)
        
        dateFormatter.dateFormat = "hh:mm a"
        let stringDateTo = dateFormatter.string(from: event.end)
        
        return "\(stringDateFrom) - \(stringDateTo)"
    }
    
    static func getDay(_ event: EventManagedObject) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: event.summit.timeZone)
        dateFormatter.dateStyle = .medium
        
        return dateFormatter.string(from: event.start)
    }
    
    static func getDateTime(_ event: EventManagedObject) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: event.summit.timeZone);
        dateFormatter.dateFormat = "EEEE dd MMMM hh:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        let stringDateFrom = dateFormatter.string(from: event.start)
        
        dateFormatter.dateFormat = "hh:mm a"
        let stringDateTo = dateFormatter.string(from: event.end)
        
        return "\(stringDateFrom) / \(stringDateTo)"
    }
    
    static func getLocation(_ event: EventManagedObject) -> String {
        
        // only show after date
        guard let startShowingVenues = event.summit.startShowingVenues,
            NSDate().mt_is(after: startShowingVenues)
            else { return "" }
        
        var location = ""
        
        if let room = event.location as? VenueRoomManagedObject {
            
            location = room.venue.name
            
            if let floorName = room.floor?.name, floorName.isEmpty == false {
                
                location += " - " + floorName
            }
            
            if room.name.isEmpty == false {
                
                location += " - " + room.name
            }
        }
        else if let venue = event.location as? VenueManagedObject {
            
            location = venue.name
        }
        
        return location
    }
    
    @inline(__always)
    static func getTrack(_ event: EventManagedObject) -> String {
        
        return event.track?.name ?? ""
    }
    
    @inline(__always)
    static func getTrackGroupColor(_ event: EventManagedObject) -> String {
        
        guard let track = event.track,
            track.groups.isEmpty == false
            else { return "" }
        
        let trackGroups = track.groups.sorted { $0.0.id < $0.1.id }
        
        return trackGroups[0].color
    }
}
