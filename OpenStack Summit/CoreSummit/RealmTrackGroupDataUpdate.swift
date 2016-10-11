//
//  RealmTrackGroupDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

extension TrackGroupDataUpdate: RealmEncodable {
    
    public func save(realm: Realm) -> RealmTrackGroup {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.color = color
        realmEntity.trackGroupDescription = descriptionText ?? ""
        realmEntity.tracks.replace(with: tracks)
        
        return realmEntity
    }
}
