//
//  ScheduleItem.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift
import CoreSummit

public struct ScheduleItem: RealmDecodable {
    
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
    
    public init(realmEntity event: RealmSummitEvent) {
        
        self.id = event.id
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

// MARK: - Private Exention

private extension ScheduleItem {
    
    static func getSummitTypes(event: RealmSummitEvent) -> String {
        var credentials = ""
        var separator = ""
        for summitType in event.summitTypes {
            credentials += separator + summitType.name
            separator = ", "
        }
        return credentials
    }
    
    static func getSponsors(event: RealmSummitEvent) -> String{
        if (event.sponsors.count == 0) {
            return ""
        }
        
        var sponsors = "Sponsored by "
        var separator = ""
        for sponsor in event.sponsors {
            sponsors += separator + sponsor.name
            separator = ", "
        }
        return sponsors
    }
    
    static func getTime(event: RealmSummitEvent) -> String {
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
    
    static func getDateTime(event: RealmSummitEvent) -> String {
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
    
    static func getLocation(event: RealmSummitEvent) -> String {
        var location = ""
        if let room = event.venueRoom {
            location = room.venue.name
            if event.summit.startShowingVenuesDate.timeIntervalSinceNow.isSignMinus {
                location += " - " + room.name
            }
        }
        else if let venue = event.venue {
            location = venue.name
        }
        return location
    }
    
    static func getTrack(event: RealmSummitEvent) -> String{
        var track = ""
        if event.presentation != nil && event.presentation!.track != nil {
            track = event.presentation!.track!.name
        }
        return track
    }
    
    static func getTrackGroupColor(event: RealmSummitEvent) -> String {
        var color = ""
        if event.presentation != nil && event.presentation!.track != nil {
            if let trackGroup = event.presentation!.track!.trackGroups.first {
                color = trackGroup.color
            }
        }
        return color
    }
}
