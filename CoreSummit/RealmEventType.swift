//
//  RealmEventType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmEventType: RealmNamed { }

// MARK: - Encoding

extension EventType: RealmDecodable {
    
    public init(realmEntity: RealmEventType) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
    }
}

extension EventType: RealmEncodable {
    
    public func save(realm: Realm) -> RealmEventType {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
                realmEntity.name = name
        
        return realmEntity
    }
}