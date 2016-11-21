//
//  EventDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

/// The `DataUpdate` version of an `Event`.
public struct EventDataUpdate: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var start: Date
    
    public var end: Date
    
    public var allowFeedback: Bool
    
    public var averageFeedback: Double
    
    public var type: Identifier
    
    public var sponsors: Set<Company>
    
    public var tags: Set<Tag>
    
    public var location: Identifier
    
    public var presentation: PresentationDataUpdate
    
    public var videos: Set<Video>
    
    public var rsvp: String?
}

public func == (lhs: EventDataUpdate, rhs: EventDataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.allowFeedback == rhs.allowFeedback
        && lhs.averageFeedback == rhs.averageFeedback
        && lhs.type == rhs.type
        && lhs.sponsors == rhs.sponsors
        && lhs.tags == rhs.tags
        && lhs.location == rhs.location
        && lhs.presentation == rhs.presentation
        && lhs.videos == rhs.videos
        && lhs.rsvp == rhs.rsvp
}
