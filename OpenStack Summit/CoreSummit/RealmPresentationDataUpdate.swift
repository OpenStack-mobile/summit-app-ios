//
//  RealmPresentationDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

extension PresentationDataUpdate: RealmEncodable {
    
    public func save(realm: Realm) -> RealmPresentation {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.level = level?.rawValue ?? ""
        realmEntity.speakers.replace(with: speakers)
        
        if let moderatorIdentifier = self.moderator {
            
            realmEntity.moderator = RealmPresentationSpeaker.cached(moderatorIdentifier, realm: realm)
            
        } else {
            
            realmEntity.moderator = nil
        }
        
        if let trackIdentifier = self.track {
            
            realmEntity.track = RealmTrack.cached(trackIdentifier, realm: realm)
            
        } else {
            
            realmEntity.track = nil
        }
        
        return realmEntity
    }
}