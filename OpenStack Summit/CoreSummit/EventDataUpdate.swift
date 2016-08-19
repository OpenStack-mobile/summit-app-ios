//
//  EventDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public extension Event {
    
    /// The `DataUpdate` version of an `Event`.
    public struct DataUpdate: Named {
        
        public let identifier: Identifier
        
        public var name: String
        
        public var descriptionText: String?
        
        public var start: Date
        
        public var end: Date
        
        public var allowFeedback: Bool
        
        public var averageFeedback: Double?
        
        public var type: Identifier
        
        public var summitTypes: [Identifier]
        
        public var sponsors: [Identifier]
        
        public var tags: [Tag]
        
        public var location: Identifier
        
        public var presentation: Presentation.DataUpdate
        
        //public var trackIdentifier: Identifier
        
        public var videos: [Video]
    }
}
