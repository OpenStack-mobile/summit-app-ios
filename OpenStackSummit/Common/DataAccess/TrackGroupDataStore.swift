//
//  TrackGroupDataStore.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/18/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol ITrackGroupDataStore {
    func getByIdLocal(id: Int) -> TrackGroup?
    func getAllLocal() -> [TrackGroup]
    func getBySearchTerm(searchTerm: String)->[TrackGroup]
}

public class TrackGroupDataStore: GenericDataStore, ITrackGroupDataStore {
    
    public func getByIdLocal(id: Int) -> TrackGroup? {
        return super.getByIdLocal(id)
    }
    
    public func getAllLocal() -> [TrackGroup] {
        return super.getAllLocal()
    }
    
    public func getBySearchTerm(searchTerm: String)->[TrackGroup] {
        let tracks = realm.objects(TrackGroup).filter("name CONTAINS [c]%@ ", searchTerm).sorted("name")
        return tracks.map { $0 }
    }
}