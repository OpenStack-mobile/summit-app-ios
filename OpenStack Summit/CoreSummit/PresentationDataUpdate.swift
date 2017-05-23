//
//  PresentationDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension Presentation {
    
    public struct DataUpdate: Unique {
        
        public let identifier: Identifier
        
        public let level: Level?
        
        public let moderator: Identifier?
        
        public let speakers: Set<Speaker>
    }
}

// MARK: - Equatable

public func == (lhs: Presentation.DataUpdate, rhs: Presentation.DataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.level == rhs.level
        && lhs.moderator == rhs.moderator
        && lhs.speakers == rhs.speakers
}
