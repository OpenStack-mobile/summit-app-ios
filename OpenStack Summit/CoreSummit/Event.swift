//
//  SummitEvent.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.URL

public struct Event: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var summit: Identifier
    
    public var descriptionText: String?
    
    public var socialDescription: String?
    
    public var start: Date
    
    public var end: Date
        
    public var track: Identifier?
    
    public var allowFeedback: Bool
    
    public var averageFeedback: Double
    
    public var type: Identifier
    
    public var rsvp: String?
    
    public var externalRSVP: Bool
    
    public var willRecord: Bool
    
    public var attachment: URL?
        
    public var sponsors: Set<Identifier>
    
    public var tags: Set<Tag>
        
    public var location: Identifier?
    
    public var presentation: Presentation
    
    public var videos: Set<Video>
    
    public var slides: Set<Slide>
    
    public var links: Set<Link>
    
    public var groups: Set<Group>
}

// MARK: - Equatable

public func == (lhs: Event, rhs: Event) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.summit == rhs.summit
        && lhs.name == rhs.name
        && lhs.summit == rhs.summit
        && lhs.descriptionText == rhs.descriptionText
        && lhs.socialDescription == rhs.socialDescription
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.track == rhs.track
        && lhs.allowFeedback == rhs.allowFeedback
        && lhs.averageFeedback == rhs.averageFeedback
        && lhs.type == rhs.type
        && lhs.sponsors == rhs.sponsors
        && lhs.tags == rhs.tags
        && lhs.location == rhs.location
        && lhs.presentation == rhs.presentation
        && lhs.videos == rhs.videos
        && lhs.rsvp == rhs.rsvp
        && lhs.groups == rhs.groups
        && lhs.externalRSVP == rhs.externalRSVP
        && lhs.willRecord == rhs.willRecord
        && lhs.slides == rhs.slides
        && lhs.links == rhs.links
}
