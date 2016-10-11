//
//  TrackGroupDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension TrackGroup {
    
    typealias DataUpdate = TrackGroupDataUpdate
}

/// The `DataUpdate` version of a `TrackGroup`.
public struct TrackGroupDataUpdate: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var color: String
    
    public var tracks: [Track]
}

