//
//  ScheduleItemAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IScheduleItemAssembler {
    
    func createDTO(event: RealmSummitEvent) -> ScheduleItem
}

public class ScheduleItemAssembler: NamedDTOAssembler, IScheduleItemAssembler {

    public func createDTO(event: SummitEvent) -> ScheduleItem {
        let ScheduleItem: ScheduleItem = super.createDTO(event)
        ScheduleItem.location = getLocation(event)
        ScheduleItem.time = getTime(event)
        ScheduleItem.dateTime = getDateTime(event)
        ScheduleItem.sponsors = getSponsors(event)
        ScheduleItem.summitTypes = getSummitTypes(event);
        ScheduleItem.eventType = event.eventType.name
        ScheduleItem.track = getTrack(event)
        ScheduleItem.trackGroupColor = getTrackGroupColor(event)
        return ScheduleItem
    }
    
    public func getSummitTypes(event: SummitEvent) -> String {
        var credentials = ""
        var separator = ""
        for summitType in event.summitTypes {
            credentials += separator + summitType.name
            separator = ", "
        }
        return credentials
    }
    
    public func getSponsors(event: SummitEvent) -> String{
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

    public func getTime(event: SummitEvent) -> String{
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

    public func getDateTime(event: SummitEvent) -> String{
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
    
    public func getLocation(event: SummitEvent) -> String{
        var location = ""
        if event.venueRoom != nil {
            location = event.venueRoom!.venue.name
            if event.summit.startShowingVenuesDate.timeIntervalSinceNow.isSignMinus {
                location += " - " + event.venueRoom!.name
            }
        }
        else if event.venue != nil {
            location = event.venue!.name
        }
        return location
    }
    
    public func getTrack(event: SummitEvent) -> String{
        var track = ""
        if event.presentation != nil && event.presentation!.track != nil {
            track = event.presentation!.track!.name
        }
        return track
    }
    
    public func getTrackGroupColor(event: SummitEvent) -> String {
        var color = ""
        if event.presentation != nil && event.presentation!.track != nil {
            if let trackGroup = event.presentation!.track!.trackGroups.first {
                color = trackGroup.color
            }
        }
        return color
    }
    
}
