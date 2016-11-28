//
//  TrackGroup.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct TrackGroup: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var color: String
        
    public var tracks: Set<Identifier>
}

// MARK: - Equatable

public func == (lhs: TrackGroup, rhs: TrackGroup) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.color == rhs.color
        && lhs.tracks == rhs.tracks
}