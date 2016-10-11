//
//  EventDetail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift
import CoreSummit

public struct EventDetail: RealmDecodable {
    
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
    
    public let venue: Identifier?
    public let eventDescription: String
    public let tags: String
    public let speakers: [PresentationSpeaker]
    public let finished: Bool
    public let allowFeedback: Bool
    public let moderator: PresentationSpeaker?
    public let level: String
    public let averageFeedback: Double
    public let video: Video?
    public let rsvp: String
    
    #if os(iOS)
    public let webpageURL: NSURL
    #endif
    
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
        self.rsvp = event.rsvp
        
        self.venue = event.venue?.id ?? event.venueRoom?.id
        
        self.finished = event.end.compare(NSDate()) == NSComparisonResult.OrderedAscending
        self.eventDescription = event.eventDescription
        self.allowFeedback = event.allowFeedback
        self.averageFeedback = event.averageFeedback
        
        var tags = ""
        var separator = ""
        for tag in event.tags {
            tags += separator + tag.name
            separator = ", "
        }
        
        self.tags = tags
        
        self.level = event.presentation != nil ? event.presentation!.level + " Level" : ""
        
        var speakers = [PresentationSpeaker]()
        var moderatorSpeaker: PresentationSpeaker?
        if let presentation = event.presentation {
            
            for speaker in presentation.speakers {
                // HACK: dismiss speakers with empty name
                if speaker.firstName.isEmpty && speaker.lastName.isEmpty {
                    continue
                }
                let speakerDTO = PresentationSpeaker(realmEntity: speaker)
                
                speakers.append(speakerDTO)
            }
            
            if let moderator = event.presentation?.moderator {
                
                moderatorSpeaker = PresentationSpeaker(realmEntity: moderator)
            }
        }
        
        self.speakers = speakers
        self.moderator = moderatorSpeaker
        
        if let video = event.videos.filter({ $0.featured }).first {
            
            self.video = Video(realmEntity: video)
            
        } else {
            
            self.video = nil
        }
        
        #if os(iOS)
        self.webpageURL = NSURL(string: Event(realmEntity: event).toWebpageURL(Summit(realmEntity: event.summit)))!
        #endif
    }
}
