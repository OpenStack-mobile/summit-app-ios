//
//  GroupEventDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/26/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct GroupEventDataUpdate: Named {
    
    public let identifier: Identifier
    
    public let name: String
    
    public let summit: Identifier
    
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
    
    public let presentation: PresentationDataUpdate
    
    public let videos: Set<Video>
    
    public let rsvp: String?
    
    public let groups: Set<Identifier>
}

// MARK: - Equatable

public func == (lhs: GroupEventDataUpdate, rhs: GroupEventDataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.summit == rhs.summit
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
        && lhs.groups == rhs.groups
}
