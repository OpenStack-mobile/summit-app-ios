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

public struct ScheduleItem: CoreDataDecodable {
    
    // MARK: - Properties
    
    public let id: Identifier
    public let name: String
    public let dateTime: String
    public let time: String
    public let location: String
    public let track: String
    public let summitTypes: String
    public let sponsors: String
    public let eventType: String
    public let trackGroupColor: String
    
    // MARK: - Initialization
    
    public init(managedObject event: EventManagedObject) {
        
        self.id = event.identifier
        self.name = event.name
        self.eventType = event.eventType.name
        self.location = ScheduleItem.getLocation(event)
        self.dateTime = ScheduleItem.getDateTime(event)
        self.time = ScheduleItem.getTime(event)
        self.track = ScheduleItem.getTrack(event)
        self.summitTypes = ScheduleItem.getSummitTypes(event)
        self.sponsors = ScheduleItem.getSponsors(event)
        self.trackGroupColor = ScheduleItem.getTrackGroupColor(event)
    }
}

// MARK: - Fetches

public extension ScheduleItem {
    
    static func search(searchTerm: String, context: NSManagedObjectContext) throws -> [ScheduleItem] {
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
        return try context.managedObjects(self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors)
    }
}

// MARK: - Internal Extension

internal extension ScheduleItem {
    
    static func getSummitTypes(event: EventManagedObject) -> String {
        var credentials = ""
        var separator = ""
        for summitType in event.summitTypes {
            credentials += separator + summitType.name
            separator = ", "
        }
        return credentials
    }
    
    static func getSponsors(event: EventManagedObject) -> String {
        
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
    
    static func getTime(event: EventManagedObject) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: event.summit.timeZone);
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        let stringDateFrom = dateFormatter.stringFromDate(event.start)
        
        dateFormatter.dateFormat = "hh:mm a"
        let stringDateTo = dateFormatter.stringFromDate(event.end)
        
        return "\(stringDateFrom) / \(stringDateTo)"
    }
    
    static func getDateTime(event: EventManagedObject) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: event.summit.timeZone);
        dateFormatter.dateFormat = "EEEE dd MMMM hh:mm a"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        let stringDateFrom = dateFormatter.stringFromDate(event.start)
        
        dateFormatter.dateFormat = "hh:mm a"
        let stringDateTo = dateFormatter.stringFromDate(event.end)
        
        return "\(stringDateFrom) / \(stringDateTo)"
    }
    
    static func getLocation(event: EventManagedObject) -> String {
        
        var location = ""
        
        if let room = event.location as? VenueRoomManagedObject {
            
            location = room.venue.name
            
            if event.summit.startShowingVenues?.timeIntervalSinceNow.isSignMinus ?? false {
                
                if let floorName = room.floor?.name
                    where floorName.isEmpty == false {
                    
                    location += " - " + floorName
                }
                
                if room.name.isEmpty == false {
                    
                    location += " - " + room.name
                }
            }
        }
        else if let venue = event.location as? VenueManagedObject {
            
            location = venue.name
        }
        
        return location
    }
    
    @inline(__always)
    static func getTrack(event: EventManagedObject) -> String {
        
        return event.presentation?.track?.name ?? ""
    }
    
    @inline(__always)
    static func getTrackGroupColor(event: EventManagedObject) -> String {
        
        return event.presentation?.track?.groups.first?.color ?? ""
    }
}
