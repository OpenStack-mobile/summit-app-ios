//
//  DataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct DataUpdate {
    
    public let identifier: Identifier
    
    public let operation: Operation
    
    public let entity: Entity
}

// MARK: - Supporting Types

public extension DataUpdate {
    
    public enum Operation: String {
        
        case Insert     = "INSERT"
        case Update     = "UPDATE"
        case Delete     = "DELETE"
        case Truncate   = "TRUNCATE"
    }
    
    public enum Entity: String {
        
        case MySchedule
        case SummitLocationImage
        case SummitLocationMap
        
        case Summit
        case SummitEvent
        case SummitType
        case Company
        case EventType
        case Feedback
        case Image
        case Location
        
        
    }
}

