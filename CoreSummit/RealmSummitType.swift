//
//  SummitTypeRealm.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmSummitType: RealmNamed {
    
    public dynamic var color = ""
}

// MARK: - Realm Encoding

extension SummitType: RealmDecodable {
    
    public init(realmEntity: RealmSummitType) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.color = realmEntity.color
    }
}

extension SummitType: RealmEncodable {
    
    public func save(realm: Realm) -> RealmSummitType {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
                realmEntity.name = name
        realmEntity.color = color
        
        return realmEntity
    }
}