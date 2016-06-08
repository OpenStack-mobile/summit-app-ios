//
//  TrackGroupDataStore.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/18/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

public protocol TrackGroupDataStoreProtocol {
    func getByIdLocal(id: Int) -> RealmTrackGroup?
    func getAllLocal() -> [RealmTrackGroup]
    func getBySearchTerm(searchTerm: String) -> [RealmTrackGroup]
}

public class TrackGroupDataStore: GenericDataStore, TrackGroupDataStoreProtocol {
    
    public func getByIdLocal(id: Int) -> RealmTrackGroup? {
        return super.getByIdLocal(id)
    }
    
    public func getAllLocal() -> [RealmTrackGroup] {
        return super.getAllLocal()
    }
    
    public func getBySearchTerm(searchTerm: String)->[TrackGroup] {
        let tracks = realm.objects(RealmTrackGroup).filter("name CONTAINS [c]%@ ", searchTerm).sorted("name")
        return tracks.map { $0 }
    }
}