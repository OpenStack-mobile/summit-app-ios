//
//  TrackDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol TrackDataStoreProtocol {
    func getAllLocal() -> [RealmTrack]
    func getBySearchTerm(searchTerm: String) -> [RealmTrack]
}

public class TrackDataStore: GenericDataStore, TrackDataStoreProtocol {
    public func getAllLocal() -> [RealmTrack] {
        return super.getAllLocal()
    }
    
    public func getBySearchTerm(searchTerm: String) -> [RealmTrack] {
        let tracks = realm.objects(RealmTrack).filter("name CONTAINS [c]%@ ", searchTerm).sorted("name")
        return tracks.map { $0 }
    }
}