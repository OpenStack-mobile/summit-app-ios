//
//  DataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift

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
        
        // Not in legacy code
        case Summit
        case SummitVenueFloor
        case PresentationLink
        case PresentationVideo
        case PresentationSlide
        case SponsorFromEvent
        
        internal var type: Updatable.Type? {
            
            switch self {
            case .WipeData: return nil
            case .MySchedule: return CoreSummit.SummitEvent.DataUpdate.self
            case .Summit: return CoreSummit.Summit.DataUpdate.self
            case .Presentation: return CoreSummit.SummitEvent.DataUpdate.self
            case .SummitEvent: return CoreSummit.SummitEvent.DataUpdate.self
            case .SummitType: return CoreSummit.SummitType.self
            case .SummitEventType: return CoreSummit.EventType.self
            case .PresentationSpeaker: return CoreSummit.PresentationSpeaker.self
            case .SummitTicketType: return CoreSummit.TicketType.self
            case .SummitVenue: return CoreSummit.Venue.self
            case .SummitVenueFloor: return CoreSummit.VenueFloor.self
            case .SummitVenueRoom: return CoreSummit.VenueRoom.self
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
        
        // truncate
        guard dataUpdate.operation != .Truncate else {
            
            guard dataUpdate.className == .WipeData
                else { return false }
            
            self.realm.deleteAll()
            self.logout()
            
            return true
        }
        
        guard dataUpdate.className != .WipeData
            else { return false }
        
        // add or remove to schedule
        guard dataUpdate.className != .MySchedule else {
            
            // should only get for authenticated requests
            guard let attendeeRole = self.authenticatedMember?.attendeeRole
                else { return false }
            
            switch dataUpdate.operation {
                
            case .Insert:
                
                guard let entityJSON = dataUpdate.entity,
                    case let .JSON(jsonObject) = entityJSON,
                    let event = Event.DataUpdate.init(JSONValue: .Object(jsonObject))
                    else { return false }
                
                try! self.realm.write {
                    
                    let realmEvent = event.save(self.realm)
                    
                    if attendeeRole.scheduledEvents.indexOf("id = %@", event.identifier) == nil {
                        
                        attendeeRole.scheduledEvents.append(realmEvent)
                    }
                }
                
                return true
                
            case .Delete:
                
                guard let entityID = dataUpdate.entity,
                    case let .Identifier(identifier) = entityID
                    else { return false }
                
                try! self.realm.write {
                    
                    if let index = attendeeRole.scheduledEvents.indexOf("id = %@", identifier) {
                        
                        attendeeRole.scheduledEvents.removeAtIndex(index)
                    }
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
                case let .Identifier(id) = entityID
                else { return false }
            
            // if it doesnt exist, dont delete it
            guard let foundEntity = type.find(id, realm: self.realm)
                else { return true }
            
            try! self.realm.write {
                
                self.realm.delete(foundEntity)
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
            entity.write(self.realm)
            
            return true
        }
    }
}

// MARK: - Private

// Must be private beacuase this is to circumvent the limitations of protocols with associated types

/// The model type can be updated remotely
internal protocol Updatable: JSONDecodable {
    
    static func find(id: Identifier, realm: Realm) -> RealmEntity?
    
    /// Encodes the object in Realm, but does not write.
    func write(realm: Realm) -> RealmEntity?
}

extension Updatable where Self: RealmEncodable {
    
    static func find(id: Identifier, realm: Realm) -> RealmEntity? {
        
        return RealmType.find(id, realm: realm)
    }
    
    func write(realm: Realm) -> RealmEntity? {
        
        var entity: RealmEntity!
        try! realm.write {
            
            entity = self.save(realm)
        }
        return entity
    }
}

// Conform to protocol
extension Summit.DataUpdate: Updatable { }
extension SummitEvent.DataUpdate: Updatable { }
extension SummitType: Updatable { }
extension EventType: Updatable { }
extension PresentationSpeaker: Updatable { }
extension TicketType: Updatable { }
extension Venue: Updatable { }
extension VenueFloor: Updatable { }
extension VenueRoom: Updatable { }
extension Track: Updatable { }
extension TrackGroupDataUpdate: Updatable { }
extension Image: Updatable { }
