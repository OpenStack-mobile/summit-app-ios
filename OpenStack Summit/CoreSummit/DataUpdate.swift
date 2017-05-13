//
//  DataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import JSON

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
        
        case insert     = "INSERT"
        case update     = "UPDATE"
        case delete     = "DELETE"
        case truncate   = "TRUNCATE"
    }
    
    public enum Entity {
        
        case identifier(CoreSummit.Identifier)
        case json(JSON.Object)
    }
    
    public enum ClassName: String {
        
        case WipeData
        case MySchedule
        case MyFavorite
        case Presentation
        case SummitEvent
        case SummitEventWithFile
        case SummitType
        case SummitEventType
        case PresentationSpeaker
        case SummitTicketType
        case SummitVenue
        case SummitVenueRoom
        case SummitAirport
        case SummitHotel
        case SummitAbstractLocation
        case SummitVenueFloor
        case PresentationCategory
        case PresentationCategoryGroup
        case PrivatePresentationCategoryGroup
        case SummitLocationMap
        case SummitLocationImage
        case Summit
        case PresentationLink
        case PresentationVideo
        case PresentationSlide
        case SponsorFromEvent
        case SummitGroupEvent
        case SummitWIFIConnection
        case SummitExternalLocation
        
        internal var type: Updatable.Type? {
            
            switch self {
            case .WipeData: return nil
            case .MySchedule, .MyFavorite: return CoreSummit.Event.DataUpdate.self
            case .Summit: return CoreSummit.Summit.DataUpdate.self
            case .Presentation: return CoreSummit.Event.DataUpdate.self
            case .SummitEvent, .SummitEventWithFile: return CoreSummit.Event.DataUpdate.self
            case .SummitGroupEvent: return CoreSummit.GroupEventDataUpdate.self
            case .SummitType: return CoreSummit.SummitType.self
            case .SummitEventType: return CoreSummit.EventType.self
            case .PresentationSpeaker: return CoreSummit.Speaker.self
            case .SummitTicketType: return CoreSummit.TicketType.self
            case .SummitVenue, .SummitExternalLocation: return CoreSummit.Venue.self
            case .SummitVenueFloor: return CoreSummit.VenueFloor.self
            case .SummitVenueRoom: return CoreSummit.VenueRoom.DataUpdate.self
            case .PresentationCategory: return CoreSummit.Track.self
            case .PresentationCategoryGroup, .PrivatePresentationCategoryGroup: return CoreSummit.TrackGroup.DataUpdate.self
            case .SummitLocationMap, .SummitLocationImage: return CoreSummit.Image.self
            case .SummitWIFIConnection: return CoreSummit.WirelessNetwork.self
            case .PresentationVideo: return CoreSummit.Video.self
            case .PresentationSlide: return CoreSummit.Slide.self
            case .PresentationLink: return CoreSummit.Link.self
                
            default: return nil
            }
        }
    }
}

// MARK: - Store

public extension Store {
    
    /// Processes the data update, but does not save the context.
    func process(dataUpdate: DataUpdate, summit: Identifier) -> Bool {
        
        let context = privateQueueManagedObjectContext
        
        return try! context.performErrorBlockAndWait {
            
            guard let summit = try SummitManagedObject.find(summit, context: context)
                else { return false }
            
            #if os(iOS)
            let authenticatedMember = try self.authenticatedMember(context)
            #else
            let authenticatedMember: MemberManagedObject? = nil
            #endif
            
            // truncate
            guard dataUpdate.operation != .truncate else {
                
                guard dataUpdate.className == .WipeData
                    else { return false }
                
                try self.clear()
                
                #if os(iOS)
                self.logout()
                #endif
                
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
                    
                case .insert:
                    
                    guard let entityJSON = dataUpdate.entity,
                        case let .json(jsonObject) = entityJSON,
                        let event = Event.DataUpdate.init(json: .object(jsonObject))
                        else { return false }
                    
                    let eventManagedObject = try event.write(context, summit: summit) as! EventManagedObject
                    
                    attendeeRole.schedule.insert(eventManagedObject)
                    
                    return true
                    
                case .delete:
                    
                    guard let entityID = dataUpdate.entity,
                        case let .identifier(identifier) = entityID
                        else { return false }
                    
                    if let eventManagedObject = try EventManagedObject.find(identifier, context: context) {
                        
                        attendeeRole.schedule.remove(eventManagedObject)
                    }
                    
                    return true
                    
                default: return false
                }
            }
            
            // add or remove to my favorites
            guard dataUpdate.className != .MyFavorite else {
                
                // should only get for authenticated requests
                guard let member = authenticatedMember
                    else { return false }
                
                switch dataUpdate.operation {
                    
                case .insert:
                    
                    guard let entityJSON = dataUpdate.entity,
                        case let .json(jsonObject) = entityJSON,
                        let event = Event.DataUpdate.init(json: .object(jsonObject))
                        else { return false }
                    
                    let eventManagedObject = try event.write(context, summit: summit) as! EventManagedObject
                    
                    member.favoriteEvents.insert(eventManagedObject)
                    
                    return true
                    
                case .delete:
                    
                    guard let entityID = dataUpdate.entity,
                        case let .identifier(identifier) = entityID
                        else { return false }
                    
                    if let eventManagedObject = try EventManagedObject.find(identifier, context: context) {
                        
                        member.favoriteEvents.remove(eventManagedObject)
                    }
                    
                    return true
                    
                default: return false
                }
            }
            
            /// we dont support all of the DataUpdate types, but thats ok
            guard let type = dataUpdate.className.type
                else { return true }
            
            // delete
            guard dataUpdate.operation != .delete else {
                
                guard let entityID = dataUpdate.entity,
                    case let .identifier(identifier) = entityID
                    else { return false }
                
                // if it doesnt exist, dont delete it
                if let foundEntity = try type.find(identifier, context: context) {
                    
                    context.delete(foundEntity)
                }
                
                return true
            }
            
            // parse JSON
            guard let entityJSON = dataUpdate.entity,
                case let .json(jsonObject) = entityJSON,
                let entity = type.init(json: .object(jsonObject))
                else { return false }
            
            switch dataUpdate.className {
                
            case .SummitLocationImage, .SummitLocationMap:
                /*
                 guard let image = entity as? Image
                 else { return false }
                 */
                return true
                
            case .SummitGroupEvent:
                
                guard let member = authenticatedMember,
                    let event = entity as? GroupEventDataUpdate
                    else { return false }
                
                // insert or update
                let managedObject = try event.save(context)
                
                // add to authenticated member's group events
                member.groupEvents.insert(managedObject)
                
                return true
                
            default:
                
                // insert or update
                let _ = try entity.write(context, summit: summit)
                
                return true
            }
        }
    }
}

// MARK: - Private

// Must be private beacuase this is to circumvent the limitations of protocols with associated types

/// The model type can be updated remotely
internal protocol Updatable: JSONDecodable {
    
    static func find(_ identifier: Identifier, context: NSManagedObjectContext) throws -> Entity?
    
    /// Encodes to CoreData.
    func write(_ context: NSManagedObjectContext, summit: SummitManagedObject) throws -> Entity
}

extension Updatable where Self: CoreDataEncodable, Self.ManagedObject: Entity {
    
    @inline(__always)
    static func find(_ identifier: Identifier, context: NSManagedObjectContext) throws -> Entity? {
        
        return try ManagedObject.find(identifier, context: context)
    }
    
    @inline(__always)
    func write(_ context: NSManagedObjectContext, summit: SummitManagedObject) throws -> Entity {
        
        return try self.save(context)
    }
}

// Conform to protocol
extension SummitType: Updatable { }
extension EventType: Updatable { }
extension Speaker: Updatable { }
extension TicketType: Updatable { }
extension Venue: Updatable { }
extension VenueFloor: Updatable { }
extension VenueRoom.DataUpdate: Updatable { }
extension Track: Updatable { }
extension TrackGroup.DataUpdate: Updatable { }
extension Image: Updatable { }
extension GroupEventDataUpdate: Updatable { }
extension WirelessNetwork: Updatable { }
extension Video: Updatable { }
extension Slide: Updatable { }
extension Link: Updatable { }
