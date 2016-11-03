//
//  DataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreData

public struct DataUpdate {
    
    public let identifier: Identifier
    
    public let date: Date
    
    public let operation: Operation
    
    public let className: ClassName
    
    public let entity: Entity?
}

// MARK: - Supporting Types

public extension DataUpdate {
    
    public enum Operation: String {
        
        case Insert     = "INSERT"
        case Update     = "UPDATE"
        case Delete     = "DELETE"
        case Truncate   = "TRUNCATE"
    }
    
    public enum Entity {
        
        case Identifier(CoreSummit.Identifier)
        case JSON(SwiftFoundation.JSON.Object)
    }
    
    public enum ClassName: String {
        
        case WipeData
        case MySchedule
        case Presentation
        case SummitEvent
        case SummitType
        case SummitEventType
        case PresentationSpeaker
        case SummitTicketType
        case SummitVenue
        case SummitVenueRoom
        case PresentationCategory
        case PresentationCategoryGroup
        case SummitLocationMap
        case SummitLocationImage
        case Summit
        case SummitVenueFloor
        case PresentationLink
        case PresentationVideo
        case PresentationSlide
        case SponsorFromEvent
        
        internal var type: Updatable.Type? {
            
            switch self {
            case .WipeData: return nil
            case .MySchedule: return CoreSummit.Event.DataUpdate.self
            case .Summit: return CoreSummit.Summit.DataUpdate.self
            case .Presentation: return CoreSummit.Event.DataUpdate.self
            case .SummitEvent: return CoreSummit.Event.DataUpdate.self
            case .SummitType: return CoreSummit.SummitType.self
            case .SummitEventType: return CoreSummit.EventType.self
            case .PresentationSpeaker: return CoreSummit.Speaker.self
            case .SummitTicketType: return CoreSummit.TicketType.self
            case .SummitVenue: return CoreSummit.Venue.self
            case .SummitVenueFloor: return CoreSummit.VenueFloor.self
            case .SummitVenueRoom: return CoreSummit.VenueRoomDataUpdate.self
            case .PresentationCategory: return CoreSummit.Track.self
            case .PresentationCategoryGroup: return CoreSummit.TrackGroupDataUpdate.self
            case .SummitLocationMap, .SummitLocationImage: return CoreSummit.Image.self
            
            default: return nil
            }
        }
    }
}

// MARK: - Store

public extension Store {
    
    func process(dataUpdate: DataUpdate) -> Bool {
        
        let context = privateQueueManagedObjectContext
        
        return try! context.performErrorBlockAndWait {
            
            let authenticatedMember = try self.authenticatedMember(context)
            
            // truncate
            guard dataUpdate.operation != .Truncate else {
                
                guard dataUpdate.className == .WipeData
                    else { return false }
                
                try self.resetContext()
                self.logout()
                
                return true
            }
            
            guard dataUpdate.className != .WipeData
                else { return false }
            
            // add or remove to schedule
            guard dataUpdate.className != .MySchedule else {
                
                // should only get for authenticated requests
                guard let attendeeRole = authenticatedMember?.attendeeRole
                    else { return false }
                
                switch dataUpdate.operation {
                    
                case .Insert:
                    
                    guard let entityJSON = dataUpdate.entity,
                        case let .JSON(jsonObject) = entityJSON,
                        let event = Event.DataUpdate.init(JSONValue: .Object(jsonObject))
                        else { return false }
                    
                    let eventManagedObject = try event.save(context)
                    
                    attendeeRole.scheduledEvents.insert(eventManagedObject)
                    
                    try context.save()
                    
                    return true
                    
                case .Delete:
                    
                    guard let entityID = dataUpdate.entity,
                        case let .Identifier(identifier) = entityID
                        else { return false }
                    
                    if let eventManagedObject = try EventManagedObject.find(identifier, context: context) {
                        
                        attendeeRole.scheduledEvents.remove(eventManagedObject)
                        
                        try context.save()
                    }
                    
                    return true
                    
                default: return false
                }
            }
            
            /// we dont support all of the DataUpdate types, but thats ok
            guard let type = dataUpdate.className.type
                else { return true }
            
            // delete
            guard dataUpdate.operation != .Delete else {
                
                guard let entityID = dataUpdate.entity,
                    case let .Identifier(identifier) = entityID
                    else { return false }
                
                // if it doesnt exist, dont delete it
                if let foundEntity = try type.find(identifier, context: context) {
                    
                    context.deleteObject(foundEntity)
                    
                    try context.save()
                }
                
                return true
            }
            
            // parse JSON
            guard let entityJSON = dataUpdate.entity,
                case let .JSON(jsonObject) = entityJSON,
                let entity = type.init(JSONValue: .Object(jsonObject))
                else { return false }
            
            switch dataUpdate.className {
                
            case .SummitLocationImage, .SummitLocationMap:
                /*
                 guard let image = entity as? Image
                 else { return false }
                 */
                return true
                
            default:
                
                // insert or update
                try entity.write(context)
                
                try context.save()
                
                return true
            }
        }
    }
}

// MARK: - Private

// Must be private beacuase this is to circumvent the limitations of protocols with associated types

/// The model type can be updated remotely
internal protocol Updatable: JSONDecodable {
    
    static func find(identifier: Identifier, context: NSManagedObjectContext) throws -> Entity?
    
    /// Encodes to CoreData.
    func write(context: NSManagedObjectContext) throws -> Entity
}

extension Updatable where Self: CoreDataEncodable, Self.ManagedObject: Entity {
    
    @inline(__always)
    static func find(identifier: Identifier, context: NSManagedObjectContext) throws -> Entity? {
        
        return try ManagedObject.find(identifier, context: context)
    }
    
    @inline(__always)
    func write(context: NSManagedObjectContext) throws -> Entity {
        
        return try self.save(context)
    }
}

// Conform to protocol
extension Summit.DataUpdate: Updatable { }
extension Event.DataUpdate: Updatable { }
extension SummitType: Updatable { }
extension EventType: Updatable { }
extension Speaker: Updatable { }
extension TicketType: Updatable { }
extension Venue: Updatable { }
extension VenueFloor: Updatable { }
extension VenueRoomDataUpdate: Updatable { }
extension Track: Updatable { }
extension TrackGroupDataUpdate: Updatable { }
extension Image: Updatable { }
