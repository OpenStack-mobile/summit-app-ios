//
//  TrackGroupDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// The `DataUpdate` version of a `TrackGroup`.
public struct TrackGroupDataUpdate: Named {
    
    public let identifier: Identifier
    
    public let name: String
    
    public let descriptionText: String?
    
    public let color: String
    
    public let tracks: Set<Track>
}

// MARK: - Equatable

public func == (lhs: TrackGroupDataUpdate, rhs: TrackGroupDataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.color == rhs.color
        && lhs.tracks == rhs.tracks
}
