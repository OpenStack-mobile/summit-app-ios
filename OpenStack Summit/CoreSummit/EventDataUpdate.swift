//
//  EventDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date

public extension Event {
    
    /// The `DataUpdate` version of an `Event`.
    public struct DataUpdate: Named {
        
        public let identifier: Identifier
        
        public let name: String
        
        public let descriptionText: String?
        
        public let socialDescription: String?
        
        public let start: Date
        
        public let end: Date
        
        public let track: Identifier?
        
        public let allowFeedback: Bool
        
        public let averageFeedback: Double
        
        public let type: Identifier
        
        public let sponsors: Set<Company>
        
        public let tags: Set<Tag>
        
        public let location: Identifier?
        
        public let presentation: Presentation.DataUpdate
        
        public let videos: Set<Video>
        
        public let slides: Set<Slide>
        
        public let links: Set<Link>
        
        public let rsvp: String?
        
        public let attachment: String?
    }
}

// MARK: - Equatable

public func == (lhs: Event.DataUpdate, rhs: Event.DataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
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
        && lhs.attachment == rhs.attachment
        && lhs.slides == rhs.slides
        && lhs.links == rhs.links
}
