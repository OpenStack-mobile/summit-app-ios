//
//  RealmTag.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//


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

// MARK: - Fetch

public extension Tag {
    
    public static func by(searchTerm searchTerm: String, realm: Realm = Store.shared.realm) -> [Tag] {
        
        let tags = realm.objects(RealmTag).filter("name CONTAINS [c] %@", searchTerm).sorted("name")
        
        return Tag.from(realm: tags)
    }
}