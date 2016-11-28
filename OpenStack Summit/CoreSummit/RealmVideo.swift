//
//  RealmVideo.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//


public class RealmVideo: RealmNamed {
    
    public dynamic var descriptionText = ""
    public dynamic var displayOnSite = false
    public dynamic var featured = false
    public dynamic var youtube = ""
}

// MARK: - Encoding

extension Video: RealmDecodable {
    
    public init(realmEntity: RealmVideo) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = String(realm: realmEntity.descriptionText)
        self.displayOnSite = realmEntity.displayOnSite
        self.featured = realmEntity.featured
        self.youtube = realmEntity.youtube
    }
}

extension Video: RealmEncodable {
    
    public func save(realm: Realm) -> RealmVideo {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.descriptionText = descriptionText ?? ""
        realmEntity.displayOnSite = displayOnSite
        realmEntity.featured = featured
        realmEntity.youtube = youtube
        
        return realmEntity
    }
}