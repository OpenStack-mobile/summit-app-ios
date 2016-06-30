//
//  RealmTrack.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTrack: RealmNamed {
    
    public let trackGroups = List<RealmTrackGroup>()
}

// MARK: - Fetches

public extension Track {
    
    static func search(searchTerm: String, realm: Realm = Store.shared.realm) -> [Track] {
        
        return Track.from(realm: realm.objects(RealmTrack).filter("name CONTAINS [c] %@", searchTerm).sorted("name"))
    }
}

// MARK: - Encoding

extension Track: RealmDecodable {
    
    public init(realmEntity: RealmTrack) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.groups = realmEntity.trackGroups.identifiers
    }
}

extension Track: RealmEncodable {
    
    public func save(realm: Realm) -> RealmTrack {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.trackGroups.replace(with: groups)
        
        return realmEntity
    }
}