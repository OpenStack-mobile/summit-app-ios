//
//  RealmSummitDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift
import struct SwiftFoundation.Date

extension SummitDataUpdate: RealmEncodable {
    
    public func save(realm: Realm) -> RealmSummit {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.startDate = start.toFoundation()
        realmEntity.endDate = end.toFoundation()
        realmEntity.timeZone = timeZone
        realmEntity.startShowingVenuesDate = startShowingVenues?.toFoundation() ?? Date(timeIntervalSince1970: 1).toFoundation()
        realmEntity.webpageURL = webpageURL
        
        // relationships
        realmEntity.types.replace(with: summitTypes.save(realm))
        realmEntity.ticketTypes.replace(with: ticketTypes.save(realm))
        
        // locations
        realmEntity.venues.removeAll()
        realmEntity.venuesRooms.removeAll()
        for location in locations {
            
            switch location {
            case let .venue(venue): realmEntity.venues.append(venue.save(realm))
            case let .room(room): realmEntity.venuesRooms.append(room.save(realm))
            }
        }
        
        return realmEntity
    }
}
