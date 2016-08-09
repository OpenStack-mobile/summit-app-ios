//
//  DataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct DataUpdate {
    
    public let identifier: Identifier
    
    public let date: Date
    
    public let operation: DataOperation
}

// MARK: - Supporting Types

public extension DataUpdate {
    
    public enum DataOperation {
        
        case Insert(JSONDecodable)
        case Update(JSONDecodable)
        case Delete(JSONDecodable.Type, Identifier)
        case Truncate
    }
    
    public enum OperationType: String {
        
        case Insert     = "INSERT"
        case Update     = "UPDATE"
        case Delete     = "DELETE"
        case Truncate   = "TRUNCATE"
    }
    
    public enum ClassName: String {
        
        case WipeData
        case MySchedule
        case SummitLocationImage
        case SummitLocationMap
        
        case Summit
        case SummitEvent
        case SummitType
        case Company
        case EventType
        case Presentation
        
        public var type: JSONDecodable.Type? {
            
            switch self {
            case .WipeData, MySchedule: return nil
            case .SummitLocationImage, SummitLocationMap: return CoreSummit.Image.self
            case .Summit: return CoreSummit.Summit.self
            case .SummitEvent: return CoreSummit.SummitEvent.self
            case .SummitType: return CoreSummit.SummitType.self
            case .Company: return CoreSummit.Company.self
            case .EventType: return CoreSummit.EventType.self
            case .Presentation: return CoreSummit.Presentation.self
            }
        }
    }
}

