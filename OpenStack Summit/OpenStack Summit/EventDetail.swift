//
//  EventDetail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

public struct EventDetail: CoreDataDecodable {
    
    // MARK: - Properties
    
    public let id: Identifier
    public let name: String
    public let summit: Identifier
    public let dateTime: String
    public let time: String
    public let location: String
    public let track: String
    public let sponsors: String
    public let eventType: String
    public let trackGroupColor: String
    
    public let venue: Identifier?
    public let eventDescription: String
    public let tags: String
    public let speakers: [SpeakerDetail]
    public let finished: Bool
    public let allowFeedback: Bool
    public let level: String
    public let averageFeedback: Double
    public let video: Video?
    public let rsvp: String
    
    public let webpageURL: NSURL
    
    // MARK: - Initialization
    
    public init(managedObject event: EventManagedObject) {
        
        self.id = event.identifier
        self.name = event.name
        self.summit = event.summit.identifier
        self.eventType = event.eventType.name
        self.location = ScheduleItem.getLocation(event)
        self.dateTime = ScheduleItem.getDateTime(event)
        self.time = ScheduleItem.getTime(event)
        self.track = ScheduleItem.getTrack(event)
        self.sponsors = ScheduleItem.getSponsors(event)
        self.trackGroupColor = ScheduleItem.getTrackGroupColor(event)
        self.rsvp = event.rsvp ?? ""
        
        self.venue = event.location?.identifier
        
        self.finished = event.end.compare(NSDate()) == .OrderedAscending
        self.eventDescription = event.descriptionText ?? ""
        self.allowFeedback = event.allowFeedback
        self.averageFeedback = event.averageFeedback
        
        var tags = ""
        var separator = ""
        for tag in event.tags {
            tags += separator + tag.name
            separator = ", "
        }
        
        self.tags = tags
        
        self.level = event.presentation.level != nil ? event.presentation.level! + " Level" : ""
        
        var speakers = [SpeakerDetail]()
        
        if let managedObject = event.presentation.moderator
            where managedObject.id > 0 {
            
            let moderatorSpeaker = CoreSummit.Speaker(managedObject: managedObject)
            let speakerDetail = SpeakerDetail(speaker: moderatorSpeaker, isModerator: true)
            speakers.append(speakerDetail)
        }
        
        let speakerManagedObjects = event.presentation.speakers
        
        let presentationSpeakers = speakerManagedObjects.map { SpeakerDetail(speaker: Speaker(managedObject: $0)) }
        
        speakers += presentationSpeakers
        
        self.speakers = speakers.sort()
        
        if let videoManagedObject = event.videos.first {
            
            self.video = Video(managedObject: videoManagedObject)
            
        } else {
            
            self.video = nil
        }
        
        let summit = Summit(managedObject: event.summit)
        
        let webpageURLString = Event(managedObject: event).toWebpageURL(summit)
        
        guard let webpageURL = NSURL(string: webpageURLString)
            else { fatalError("Invalid URLL \(webpageURLString)") }
        
        self.webpageURL = webpageURL
    }
}

// MARK: - Supporting Types

public extension EventDetail {
    
    public struct SpeakerDetail: Person {
        
        public let identifier: Identifier
        
        public let firstName: String
        
        public let lastName: String
        
        public let title: String?
        
        public let pictureURL: String
        
        public let twitter: String?
        
        public let irc: String?
        
        public let biography: String?
        
        public let isModerator: Bool
        
        private init(speaker: Speaker, isModerator: Bool = false) {
            
            self.identifier = speaker.identifier
            self.firstName = speaker.firstName
            self.lastName = speaker.lastName
            self.title = speaker.title
            self.pictureURL = speaker.pictureURL
            self.twitter = speaker.twitter
            self.irc = speaker.irc
            self.biography = speaker.biography
            self.isModerator = isModerator
        }
    }
}

public func == (lhs: EventDetail.SpeakerDetail, rhs: EventDetail.SpeakerDetail) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.title == rhs.title
        && lhs.pictureURL == rhs.pictureURL
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.biography == rhs.biography
        && lhs.isModerator == rhs.isModerator
}
