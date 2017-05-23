//
//  EventDetail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import Foundation
import CoreSummit

struct EventDetail {
    
    let identifier: Identifier
    let name: String
    let summit: Identifier
    let start: Date
    let end: Date
    let timeZone: String
    let dateTime: String
    let day: String
    let time: String
    let location: String
    let track: String
    let sponsors: String
    let eventType: String
    let trackGroupColor: String
    
    let venue: Location?
    let eventDescription: String
    let socialDescription: String
    let tags: String
    let speakers: [SpeakerDetail]
    let finished: Bool
    let allowFeedback: Bool
    let level: String
    let averageFeedback: Double
    let video: Video?
    let willRecord: Bool
    let rsvp: URL?
    let externalRSVP: Bool
    let attachment: URL?
    let webpage: URL
}

// MARK: - CoreData

extension EventDetail: CoreDataDecodable {
    
    init(managedObject event: EventManagedObject) {
        
        self.identifier = event.id
        self.name = event.name
        self.summit = event.summit.id
        self.start = event.start
        self.end = event.end
        self.timeZone = event.summit.timeZone
        self.eventType = event.eventType.name
        self.location = ScheduleItem.getLocation(event)
        self.dateTime = ScheduleItem.getDateTime(event)
        self.day = ScheduleItem.getDay(event)
        self.time = ScheduleItem.getTime(event)
        self.track = ScheduleItem.getTrack(event)
        self.sponsors = ScheduleItem.getSponsors(event)
        self.trackGroupColor = ScheduleItem.getTrackGroupColor(event)
        self.rsvp = URL(string: event.rsvp ?? "")
        self.externalRSVP = event.externalRSVP
        self.willRecord = event.willRecord
        self.attachment = URL(string: event.attachment ?? "") ?? Slide.from(managedObjects: event.slides).ordered().first?.link
        
        if let locationManagedObject = event.location {
            
            self.venue = Location(managedObject: locationManagedObject)
            
        } else {
            
            self.venue = nil
        }
        
        self.finished = event.end.compare(NSDate() as Date) == .orderedAscending
        self.eventDescription = event.descriptionText ?? ""
        self.socialDescription = event.socialDescription ?? ""
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
        
        if let managedObject = event.presentation.moderator,
            managedObject.id > 0 {
            
            let moderatorSpeaker = CoreSummit.Speaker(managedObject: managedObject)
            let speakerDetail = SpeakerDetail(speaker: moderatorSpeaker, isModerator: true)
            speakers.append(speakerDetail)
        }
        
        let speakerManagedObjects = event.presentation.speakers
        
        let presentationSpeakers = speakerManagedObjects.map { SpeakerDetail(speaker: Speaker(managedObject: $0)) }
        
        speakers += presentationSpeakers
        
        self.speakers = speakers.sorted()
        
        self.video = Video.from(managedObjects: event.videos).sorted().first
        
        let summit = Summit(managedObject: event.summit)
        
        self.webpage = Event(managedObject: event).webpage(for: summit)
    }
}

// MARK: - Supporting Types

extension EventDetail {
    
    struct SpeakerDetail: Person {
        
        let identifier: Identifier
        
        let firstName: String
        
        let lastName: String
        
        let title: String?
        
        let picture: URL
        
        let twitter: String?
        
        let irc: String?
        
        var linkedIn: String? { return nil }
        
        let biography: String?
        
        let isModerator: Bool
                
        fileprivate init(speaker: Speaker, isModerator: Bool = false) {
            
            self.identifier = speaker.identifier
            self.firstName = speaker.firstName
            self.lastName = speaker.lastName
            self.title = speaker.title
            self.picture = speaker.picture
            self.twitter = speaker.twitter
            self.irc = speaker.irc
            self.biography = speaker.biography
            self.isModerator = isModerator
        }
    }
}

func == (lhs: EventDetail.SpeakerDetail, rhs: EventDetail.SpeakerDetail) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.title == rhs.title
        && lhs.picture == rhs.picture
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.biography == rhs.biography
        && lhs.isModerator == rhs.isModerator
}
