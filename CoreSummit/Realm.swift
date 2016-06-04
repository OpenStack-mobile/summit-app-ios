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

public protocol RealmEncodable {
    
    associatedtype RealmType: RealmEntity
    
    /// Encodes the object in Realm, but does not write.
    func save(realm: Realm) -> RealmType
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
    
    func replace(with array: [Element]) {
        
        removeAll()
        
        array.forEach { append($0) }
    }
    
    func replace(with identifiers: [Identifier]) {
        
        assert(self.realm != nil, "List must belong to a Realm")
        
        let cached = identifiers.map { Element.cached($0, realm: self.realm!) }
        
        replace(with: cached)
    }
    
    func replace<Encodable: RealmEncodable where Encodable.RealmType == Element>(with encodables: [Encodable]) {
        
        assert(self.realm != nil, "List must belong to a Realm")
        
        replace(with: encodables.save(realm!))
    }
}

public extension RealmEntity {
    
    static func find(id: Identifier, realm: Realm) -> Self? {
        
        return realm.objects(self).filter("id = \(id)").first
    }
    
    /// Realm find or create. If the object is not cached,
    static func cached(id: Identifier, realm: Realm) -> Self {
        
        // find existing
        if let cached = self.find(id, realm: realm) {
            
            return cached
        }
        
        let new = self.init()
        new.id = id
        
        realm.add(new)
        
        return new
    }
}

public extension CollectionType where Generator.Element: RealmEncodable {
    
    func save(realm: Realm) -> [Generator.Element.RealmType] {
        
        return map { $0.save(realm) }
    }
}


