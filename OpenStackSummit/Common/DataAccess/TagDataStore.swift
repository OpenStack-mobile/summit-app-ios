//
//  TagDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITagDataStore {
    func getAllLocal() -> [Tag]
    func getTagsBySearchTerm(searchTerm: String) -> [Tag]
}

public class TagDataStore: GenericDataStore, ITagDataStore {
    public func getAllLocal() -> [Tag] {
        return super.getAllLocal()
    }
    
    public func getTagsBySearchTerm(searchTerm: String) -> [Tag] {
        let tags = realm.objects(Tag).filter("name CONTAINS [c]%@", searchTerm).sorted("name")
        return tags.map { $0 }
    }
}