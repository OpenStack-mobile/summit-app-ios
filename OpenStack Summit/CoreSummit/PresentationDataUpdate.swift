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
        
        public var level: Level?
        
        public var track: Identifier?
        
        public var moderator: Identifier?
        
        public var speakers: [PresentationSpeaker]
    }
}