//
//  RealmTag.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTag: RealmNamed { }

// MARK: - Encoding

extension Tag: RealmDecodable {
    
    public init(realmEntity: RealmTag) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
    }
}

extension Tag: RealmEncodable {
    
    public func save(realm: Realm) -> RealmTag {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        
        return realmEntity
    }
}