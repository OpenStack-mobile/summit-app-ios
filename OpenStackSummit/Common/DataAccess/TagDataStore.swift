//
//  TagDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol TagDataStoreProtocol {
    
    func getAllLocal() -> [RealmTag]
    func getTagsBySearchTerm(searchTerm: String) -> [RealmTag]
}

public class TagDataStore: GenericDataStore, TagDataStoreProtocol {
    
    public func getAllLocal() -> [RealmTag] {
        return super.getAllLocal()
    }
    
    public func getTagsBySearchTerm(searchTerm: String) -> [RealmTag] {
        let tags = realm.objects(RealmTag).filter("name CONTAINS [c]%@", searchTerm).sorted("name")
        return tags.map { $0 }
    }
}