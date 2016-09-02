//
//  EventDetail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit

public struct EventDetail {
    
    // MARK: - Properties
    
    public let identifier: Identifier
    public let name: String
    public let dateTime: String
    public let time: String
    public let location: String
    public let track: String
    public let summitTypes: String
    public let sponsors: String
    public let eventType: String
    public let trackGroupColor: String
    
    public let venue: Identifier?
    public let descriptionText: String?
    public let tags: String
    public let speakers: [PresentationSpeaker]
    public let finished: Bool
    public let allowFeedback: Bool
    public let moderator: PresentationSpeaker?
    public let level: String
    public let averageFeedback: Double?
    public let video: Video?
    public let webpageURL: NSURL
    
    // MARK: - Initialization
    
    public init(event: Event, summit: Summit) {
        
        self.identifier = event.identifier
        self.name = event.name
        self.eventType = summit.eventTypes.firstMatching({ $0.identifier == event.type })!.name
        self.location = EventDetail.getLocation(event, summit: summit)
        self.dateTime = EventDetail.getDateTime(event, summit: summit)
        self.time = EventDetail.getTime(event, summit: summit)
        self.track = EventDetail.getTrack(event, summit: summit)
        self.summitTypes = EventDetail.getSummitTypes(event, summit: summit)
        self.sponsors = EventDetail.getSponsors(event, summit: summit)
        self.trackGroupColor = EventDetail.getTrackGroupColor(event, summit: summit)
        
        self.venue = event.location
        
        self.finished = event.end > Date()
        self.descriptionText = event.descriptionText
        self.allowFeedback = event.allowFeedback
        self.averageFeedback = event.averageFeedback
        
        var tags = ""
        var separator = ""
        for tag in event.tags {
            tags += separator + tag.name
            separator = ", "
        }
        
        self.tags = tags
        
        self.level = event.presentation != nil ? event.presentation!.level!.rawValue + " Level" : ""
        
        var speakers = [PresentationSpeaker]()
        var moderatorSpeaker: PresentationSpeaker?
        if let presentation = event.presentation {
            
            for speakerID in presentation.speakers {
                
                let speaker = summit.speakers.firstMatching({ $0.identifier == speakerID })!
                
                // HACK: dismiss speakers with empty name
                if speaker.firstName.isEmpty && speaker.lastName.isEmpty {
                    continue
                }
                
                speakers.append(speaker)
            }
            
            if let moderator = event.presentation?.moderator where moderator != 0 {
                
                moderatorSpeaker = summit.speakers.firstMatching({ $0.identifier == moderator })!
            }
        }
        
        self.speakers = speakers
        self.moderator = moderatorSpeaker
        
        self.video = event.videos.filter({ $0.featured }).first
        
        self.webpageURL = NSURL(string: event.toWebpageURL(AppEnvironment, summit: summit))!
    }
}

// MARK: - Internal Extension

internal extension EventDetail {
    
    static func getSummitTypes(event: Event, summit: Summit) -> String {
        var credentials = ""
        var separator = ""
        for summitTypeID in event.summitTypes {
            let summitType = summit.summitTypes.firstMatching({ summitTypeID == $0.identifier })!
            credentials += separator + summitType.name
            separator = ", "
        }
        return credentials
    }
    
    static func getSponsors(event: SummitEvent, summit: Summit) -> String {
        
        guard event.sponsors.isEmpty == false
            else { return "" }
        
        var sponsors = "Sponsored by "
        var separator = ""
        for sponsorID in event.sponsors {
            let sponsor = summit.sponsors.firstMatching({ sponsorID == $0.identifier })!
            sponsors += separator + sponsor.name
            separator = ", "
            assert(sponsor.name.isEmpty == false, "Empty sponsor name")
        }
        return sponsors
    }
    
    static func getTime(event: SummitEvent, summit: Summit) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone);
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        let stringDateFrom = dateFormatter.stringFromDate(event.start.toFoundation())
        
        dateFormatter.dateFormat = "hh:mm a"
        let stringDateTo = dateFormatter.stringFromDate(event.end.toFoundation())
        
        return "\(stringDateFrom) / \(stringDateTo)"
    }
    
    static func getDateTime(event: SummitEvent, summit: Summit) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone);
        dateFormatter.dateFormat = "EEEE dd MMMM hh:mm a"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        let stringDateFrom = dateFormatter.stringFromDate(event.start.toFoundation())
        
        dateFormatter.dateFormat = "hh:mm a"
        let stringDateTo = dateFormatter.stringFromDate(event.end.toFoundation())
        
        return "\(stringDateFrom) / \(stringDateTo)"
    }
    
    static func getLocation(event: SummitEvent, summit: Summit) -> String {
        
        guard let locationID = event.location
            where locationID != 0
            else { return "" }
        
        let location = summit.locations.map({ $0.rawValue }).firstMatching({ $0.identifier == locationID })!
        
        if let room = location as? VenueRoom {
            
            let venue = summit.locations.map({ $0.rawValue }).firstMatching({ $0.identifier == room.venue })!
            
            return venue.name + " - " + room.name
            
        } else {
            
            return location.name
        }
    }
    
    static func getTrack(event: SummitEvent, summit: Summit) -> String {
        
        guard let trackID = event.presentation?.track
            else { return "" }
        
        return summit.tracks.firstMatching({ $0.identifier == trackID })!.name
    }
    
    static func getTrackGroupColor(event: SummitEvent, summit: Summit) -> String {
        
        guard let trackID = event.presentation?.track,
            let track = summit.tracks.firstMatching({ $0.identifier == trackID }),
            let trackGroupID = track.groups.first,
            let trackGroup = summit.trackGroups.firstMatching({ $0.identifier == trackGroupID })
            else { return "" }
        
        return trackGroup.color
    }
}
