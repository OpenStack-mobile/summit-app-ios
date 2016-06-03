//
//  Realm.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmEntity: Object {
    
    public dynamic var id = 0
    
    public override class func primaryKey() -> String {
        return "id"
    }
}

public protocol RealmDecodable {
    
    associatedtype RealmType: RealmEntity
    
    init(realmEntity: RealmType)
}

public extension RealmDecodable {
    
    static func from(realm realmEntities: [RealmType]) -> [Self] {
        
        return realmEntities.map { self.init(realmEntity: $0) }
    }
    
    static func from(realm realmEntities: List<RealmType>) -> [Self] {
        
        return realmEntities.map { self.init(realmEntity: $0) }
    }
}

public extension List where T: RealmEntity {
    
    var identifiers: [Identifier] { return self.map { $0.id } }
}

public protocol RealmEncodable {
    
    associatedtype RealmType: RealmEntity
    
    func save(realm: Realm) throws -> RealmType
}