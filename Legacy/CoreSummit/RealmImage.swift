//
//  RealmImage.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmImage: RealmEntity {
    public dynamic var url = ""
}

// MARK: - Encoding

extension Image: RealmDecodable {
    
    public init(realmEntity: RealmImage) {
        
        self.identifier = realmEntity.id
        self.url = realmEntity.url
    }
}

extension Image: RealmEncodable {
    
    public func save(realm: Realm) -> RealmImage {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.url = url
        
        return realmEntity
    }
}