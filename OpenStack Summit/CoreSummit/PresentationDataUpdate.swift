//
//  PresentationDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct PresentationDataUpdate: Unique {
    
    public let identifier: Identifier
    
    public let level: Presentation.Level?
    
    public let moderator: Identifier?
    
    public let speakers: Set<Speaker>
}

// MARK: - Equatable

public func == (lhs: PresentationDataUpdate, rhs: PresentationDataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.level == rhs.level
        && lhs.moderator == rhs.moderator
        && lhs.speakers == rhs.speakers
}
