//
//  RealmEventDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift
import struct SwiftFoundation.Date

extension SummitEvent.DataUpdate: RealmEncodable {
    
    public func save(realm: Realm) -> RealmSummitEvent {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.start = start.toFoundation()
        realmEntity.end = end.toFoundation()
        realmEntity.eventDescription = descriptionText ?? ""
        realmEntity.allowFeedback = allowFeedback
        realmEntity.averageFeedback = averageFeedback
        
        // relationships
        realmEntity.eventType = RealmEventType.cached(type, realm: realm)
        realmEntity.summitTypes.replace(with: summitTypes)
        realmEntity.sponsors.replace(with: sponsors)
        realmEntity.tags.replace(with: tags)
        realmEntity.presentation = presentation.save(realm)
        realmEntity.videos.replace(with: videos)
        
        // location
        if let cachedRoom = RealmVenueRoom.find(location, realm: realm) {
            
            realmEntity.venueRoom = cachedRoom
            realmEntity.venue = nil
            
        } else if let cachedVenue = RealmVenue.find(location, realm: realm) {
            
            realmEntity.venue = cachedVenue
            realmEntity.venueRoom = nil
            
        } else {
            
            fatalError("Missing location \(location) for event: \(realmEntity)")
        }
        
        return realmEntity
    }
}